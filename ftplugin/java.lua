-- ------------------------------------------------------------ Java (jdtls) ------------------------------------------------------------
-- ftplugin for Java development using Eclipse JDT Language Server.
-- Mission: Configure and launch jdtls with a production-grade setup for JVM
-- development (Maven/Gradle project detection, debug/test bundles, runtime
-- discovery, completion, code lenses, formatting, and refactoring keymaps).

local ok, jdtls = pcall(require, "jdtls")
if not ok then
  return
end

local vim = vim
local fn, fs = vim.fn, vim.fs

local mason_settings = require("mason.settings").current
local MASON_PACKAGES_DIR = mason_settings.install_root_dir .. "/packages"
local JDTLS_PATH = MASON_PACKAGES_DIR .. "/jdtls"
local JAR_PATH = fn.glob(JDTLS_PATH .. "/plugins/org.eclipse.equinox.launcher_*.jar", true, true)[1]
if not JAR_PATH then
  require("utils.notify").error("jdtls not found — run :MasonInstall jdtls")
  return
end

local JDEBUG_PATH = MASON_PACKAGES_DIR .. "/java-debug-adapter"
local JTEST_PATH = MASON_PACKAGES_DIR .. "/java-test"

--- Detect the host OS for the jdtls config folder name.
local sysname = (vim.uv or vim.loop).os_uname().sysname
local os_name = sysname == "Linux" and "linux" or sysname == "Darwin" and "mac" or "win"

--- Resolve the project root directory using common Java build markers.
local root_markers = { ".git", "pom.xml", "build.gradle", "settings.gradle", "gradlew", "mvnw" }
local root_dir = fs.root(0, root_markers)
if not root_dir then
  return
end

local project_name = fs.basename(root_dir)

--- Workspace root used by jdtls to store per-project metadata.
local workspace_dir = fn.stdpath("cache") .. "/site/java/workspace-root/" .. project_name
if fn.isdirectory(workspace_dir) == 0 then
  fn.mkdir(workspace_dir, "p")
end

--- Locate a JDK on the system, preferring recent LTS releases.
--- @return string|nil java_path, table|nil runtime_info
local function find_java()
  local java_candidates = {
    { path = "/usr/lib/jvm/java-21-openjdk/bin/java", name = "21" },
    { path = "/usr/lib/jvm/java-23-openjdk/bin/java", name = "23" },
    { path = "/usr/lib/jvm/java-17-openjdk/bin/java", name = "17" },
  }

  for _, candidate in ipairs(java_candidates) do
    if fn.filereadable(candidate.path) == 1 then
      return candidate.path, { name = candidate.name .. "-openjdk", path = candidate.path }
    end
  end

  local system_java = fn.exepath("java")
  if system_java ~= "" then
    return system_java, { name = "system", path = system_java }
  end

  return nil, nil
end

local java_path, runtime_info = find_java()
if not java_path then
  require("utils.notify").error("JDK not found — install a Java 17+ JDK")
  return
end

-- Extend JDTLS client capabilities with additional text edits support.
local extended_capabilities = jdtls.extendedClientCapabilities
extended_capabilities.resolveAdditionalTextEditsSupport = true

-- Assemble debug/test bundles for the debugger to consume.
local bundles = {}
if fn.isdirectory(JDEBUG_PATH) == 1 then
  vim.list_extend(
    bundles,
    fn.glob(JDEBUG_PATH .. "/extension/server/com.microsoft.java.debug.plugin-*.jar", true, true)
  )
end
if fn.isdirectory(JTEST_PATH) == 1 then
  vim.list_extend(bundles, fn.glob(JTEST_PATH .. "/extension/server/*.jar", true, true))
end

local capabilities = require("core.lsp").make_default_capabilities()

local config = {
  cmd = {
    java_path,
    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.defaultStartLevel=4",
    "-Declipse.product=org.eclipse.jdt.ls.core.product",
    "-Dlog.protocol=true",
    "-Dlog.level=ALL",
    "-javaagent:" .. JDTLS_PATH .. "/lombok.jar",
    "-Xmx1g",
    "--add-modules=ALL-SYSTEM",
    "--add-opens",
    "java.base/java.util=ALL-UNNAMED",
    "--add-opens",
    "java.base/java.lang=ALL-UNNAMED",
    "--add-opens",
    "java.base/java.reflect=ALL-UNNAMED",
    "--add-opens",
    "java.base/java.text=ALL-UNNAMED",
    "--add-opens",
    "java.base/java.nio=ALL-UNNAMED",
    "-jar",
    JAR_PATH,
    "-configuration",
    JDTLS_PATH .. "/config_" .. os_name,
    "-data",
    workspace_dir,
  },
  root_dir = root_dir,
  capabilities = capabilities,
  init_options = {
    extendedClientCapabilities = extended_capabilities,
    bundles = bundles,
  },
  on_attach = function(client, bufnr)
    jdtls.setup_dap({ hotcodereplace = "auto" })
    require("jdtls.dap").setup_dap_main_class_configs()
    require("jdtls.setup").add_commands()

  end,
  settings = {
    java = {
      eclipse = { downloadSources = true },
      maven = { downloadSources = true },
      implementationsCodeLens = { enabled = true },
      referencesCodeLens = { enabled = true },
      references = { includeDecompiledSources = true },
      signatureHelp = { enabled = true },
      contentProvider = { preferred = "fernflower" },
      format = { enabled = true },
      completion = {
        favoriteStaticMembers = {
          "org.hamcrest.MatcherAssert.assertThat",
          "org.hamcrest.Matchers.*",
          "org.hamcrest.CoreMatchers.*",
          "org.junit.jupiter.api.Assertions.*",
          "java.util.Objects.requireNonNull",
          "java.util.Objects.requireNonNullElse",
          "org.mockito.Mockito.*",
        },
        filteredTypes = {
          "com.sun.*",
          "io.micrometer.shaded.*",
          "java.awt.*",
          "jdk.*",
          "sun.*",
        },
        importOrder = { "java", "javax", "com", "org" },
      },
      sources = {
        organizeImports = {
          starThreshold = 9999,
          staticStarThreshold = 9999,
        },
      },
      codeGeneration = {
        toString = {
          template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
        },
        hashCodeEquals = { useJava7Objects = true },
        useBlocks = true,
      },
      configuration = {
        runtimes = runtime_info and { runtime_info } or {},
      },
    },
  },
  flags = {
    debounce_text_changes = 150,
    allow_incremental_sync = true,
  },
}

jdtls.start_or_attach(config)
