local ok, jdtls = pcall(require, "jdtls")
if not ok then
    return
end

local uv = vim.uv or vim.loop
local fs = vim.fs
local bufnr = vim.api.nvim_get_current_buf()
local bufname = vim.api.nvim_buf_get_name(bufnr)

-- Skip virtual/empty buffers early (jdt://, fugitive://, unnamed, ...)
if bufname == "" or bufname:match("^%a[%w+.-]*://") then
    return
end

-- ============================================================
-- Root detection
-- Priority: wrapper/settings (multi-module root) > .git > single-module marker
-- ============================================================
local root_dir = fs.root(bufnr, { "mvnw", "gradlew", "settings.gradle", "settings.gradle.kts" })
    or fs.root(bufnr, { ".git" })
    or fs.root(bufnr, { "pom.xml", "build.gradle", "build.gradle.kts" })
if not root_dir then
    return
end

local function isdir(p)
    local s = uv.fs_stat(p)
    return s ~= nil and s.type == "directory"
end

-- ============================================================
-- Expensive environment discovery: run ONCE per Neovim session
-- ============================================================
local MIN_JAVA = 25  -- jdtls 1.63 requires JDK 25+

local function build_env()
    local packages = require("mason.settings").current.install_root_dir .. "/packages"
    local jdtls_path = packages .. "/jdtls"

    if not isdir(jdtls_path .. "/plugins") then
        return nil, "jdtls not found — run :MasonInstall jdtls"
    end

    local jar
    for name, typ in fs.dir(jdtls_path .. "/plugins") do
        if typ == "file" and name:match("^org%.eclipse%.equinox%.launcher_.*%.jar$") then
            jar = jdtls_path .. "/plugins/" .. name
            break
        end
    end
    if not jar then
        return nil, "jdtls launcher jar not found — run :MasonInstall jdtls"
    end

    local sysname = uv.os_uname().sysname
    local os_name = sysname == "Linux" and "linux" or sysname == "Darwin" and "mac" or "win"
    local exe = os_name == "win" and ".exe" or ""

    -- ---------- JDK discovery ----------
    local home_dir = vim.env.HOME or vim.env.USERPROFILE or ""
    local search_roots = {
        "/usr/lib/jvm",
        "/Library/Java/JavaVirtualMachines",
        home_dir .. "/.sdkman/candidates/java",
        home_dir .. "/.asdf/installs/java",
        home_dir .. "/.local/share/mise/installs/java",
        home_dir .. "/.jdks",
        "/opt/java",
        "/opt",
    }

    local function is_valid_jdk(home)
        local java = uv.fs_stat(home .. "/bin/java" .. exe)
        local javac = uv.fs_stat(home .. "/bin/javac" .. exe)
        if not (java and javac and java.type == "file" and javac.type == "file") then
            return false
        end
        -- Unix: ensure the binary is actually executable
        if os_name ~= "win" then
            return uv.fs_access(home .. "/bin/java", "X") == true
        end
        return true
    end

    --- "21.0.5" -> { 21, 0, 5 }
    local function version_parts(v)
        local parts = {}
        for n in v:gmatch("%d+") do
            parts[#parts + 1] = tonumber(n)
        end
        return parts
    end

    -- Reading `release` is instant; no process is spawned
    local function parts_from_release(home)
        local f = io.open(home .. "/release", "r")
        if not f then return nil end
        local content = f:read("*a")
        f:close()
        local v = content:match('JAVA_VERSION="([^"]+)"')
        return v and version_parts(v) or nil
    end

    local function major_from_name(dirname)
        local lower = dirname:lower()
        local m = lower:match("java%-(%d+)") or lower:match("jdk%-(%d+)")
            or lower:match("jdk(%d+)") or lower:match("jre%-(%d+)")
        if m then return tonumber(m) end
        local v = lower:match("(%d+%.%d+%.%d+)")
        return v and tonumber(v:match("^(%d+)")) or nil
    end

    local jdks, seen = {}, {}
    local function add_jdk(path, from_env)
        local real = uv.fs_realpath(path) -- resolves symlinks (e.g. sdkman "current")
        if not real then return end
        local home = real
        if uv.fs_stat(real .. "/Contents/Home/bin/java") then -- macOS bundle layout
            home = real .. "/Contents/Home"
        end
        if seen[home] or not is_valid_jdk(home) then return end

        local parts = parts_from_release(home)
        local major = parts and parts[1] or major_from_name(fs.basename(real))
        if not major or major < MIN_JAVA then return end

        seen[home] = true
        jdks[#jdks + 1] = {
            path = home,
            major = major,
            parts = parts or { major },
            from_env = from_env or false,
        }
    end

    if vim.env.JAVA_HOME and vim.env.JAVA_HOME ~= "" then
        add_jdk(vim.env.JAVA_HOME, true)
    end
    for _, root in ipairs(search_roots) do
        if isdir(root) then
            for name, typ in fs.dir(root) do
                if typ == "directory" or typ == "link" then
                    add_jdk(root .. "/" .. name)
                end
            end
        end
    end

    if #jdks == 0 then
        return nil, ("No JDK %d+ found (need bin/java + bin/javac)"):format(MIN_JAVA)
    end

    -- Order: higher major > JAVA_HOME > newer patch version > path
    table.sort(jdks, function(a, b)
        if a.major ~= b.major then return a.major > b.major end
        if a.from_env ~= b.from_env then return a.from_env end
        for i = 1, math.max(#a.parts, #b.parts) do
            local x, y = a.parts[i] or 0, b.parts[i] or 0
            if x ~= y then return x > y end
        end
        return a.path < b.path
    end)

    -- jdtls requires standard, unique names (JavaSE-25, ...):
    -- keep the preferred JDK of each major
    local runtimes, used = {}, {}
    for _, jdk in ipairs(jdks) do
        if not used[jdk.major] then
            used[jdk.major] = true
            runtimes[#runtimes + 1] = {
                name = "JavaSE-" .. jdk.major,
                path = jdk.path,
                default = (#runtimes == 0),
            }
        end
    end

    -- Every JDK is already 25+, so the preferred one runs jdtls
    local runner = jdks[1]

    -- ---------- debug/test bundles ----------
    local bundles = {}
    local function add_bundles(dir, pattern, exclude)
        if not isdir(dir) then return end
        for name, typ in fs.dir(dir) do
            if typ == "file" and name:match(pattern) and not (exclude and exclude[name]) then
                bundles[#bundles + 1] = dir .. "/" .. name
            end
        end
    end

    add_bundles(packages .. "/java-debug-adapter/extension/server",
        "^com%.microsoft%.java%.debug%.plugin%-.*%.jar$")
    -- These two jars must not be loaded as bundles
    add_bundles(packages .. "/java-test/extension/server", ".*%.jar$", {
        ["com.microsoft.java.test.runner-jar-with-dependencies.jar"] = true,
        ["jacocoagent.jar"] = true,
    })

    local lombok = jdtls_path .. "/lombok.jar"

    return {
        jar = jar,
        jdtls_path = jdtls_path,
        os_name = os_name,
        runtimes = runtimes,
        java_path = runner.path .. "/bin/java" .. exe,
        java_major = runner.major,
        bundles = bundles,
        lombok = uv.fs_stat(lombok) and lombok or nil,
    }
end

if not _G.__jdtls_env then
    local built, err = build_env()
    if not built then
        require("utils.notify").error(err)
        return
    end
    _G.__jdtls_env = built
end
local env = _G.__jdtls_env

-- ============================================================
-- Workspace: stable path derived from root_dir (no process spawn)
-- ============================================================
local function hash_path(p)
    local h = 0
    for i = 1, #p do
        h = (h * 31 + p:byte(i)) % 0xFFFFFFFF
    end
    return ("%08x"):format(h)
end

local workspace_dir = ("%s/site/java/workspace-root/%s-%s"):format(
    vim.fn.stdpath("cache"),
    fs.basename(root_dir),
    hash_path(root_dir)
)
if not uv.fs_stat(workspace_dir) then
    vim.fn.mkdir(workspace_dir, "p")
end

-- ============================================================
-- jdtls config
-- ============================================================
local extended_capabilities = jdtls.extendedClientCapabilities
extended_capabilities.resolveAdditionalTextEditsSupport = true

local cmd = {
    env.java_path,
    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.defaultStartLevel=4",
    "-Declipse.product=org.eclipse.jdt.ls.core.product",
    "-Dsun.zip.disableMemoryMapping=true",
    "-XX:+UseParallelGC",
    "-XX:GCTimeRatio=4",
    "-XX:AdaptiveSizePolicyWeight=90",
    "-Xms256m",
    "-Xmx2g",
    "--add-modules=ALL-SYSTEM",
    "--add-opens", "java.base/java.util=ALL-UNNAMED",
    "--add-opens", "java.base/java.lang=ALL-UNNAMED",
    "--add-opens", "java.base/java.lang.reflect=ALL-UNNAMED",
    "--add-opens", "java.base/java.text=ALL-UNNAMED",
    "--add-opens", "java.base/java.nio=ALL-UNNAMED",
    "-jar", env.jar,
    "-configuration", env.jdtls_path .. "/config_" .. env.os_name,
    "-data", workspace_dir,
}
-- JVM options must stay right after the executable
if env.lombok then
    table.insert(cmd, 2, "-javaagent:" .. env.lombok)
end
if env.java_major >= 23 then
    table.insert(cmd, 2, "--sun-misc-unsafe-memory-access=allow")
end

local config = {
    cmd = cmd,
    root_dir = root_dir,
    capabilities = require("core.lsp").make_default_capabilities(),
    init_options = {
        extendedClientCapabilities = extended_capabilities,
        bundles = env.bundles,
    },
    on_attach = function(client, _)
        require("jdtls.setup").add_commands()
        client.commands["_java.reloadBundles.command"] = function()
            return {}
        end

        -- Debug/test setup once per client, not on every buffer attach
        if #env.bundles > 0 and not client._dap_configured then
            client._dap_configured = true
            jdtls.setup_dap({ hotcodereplace = "auto" })
            -- main-class discovery needs an imported project
            vim.defer_fn(function()
                local ok2, err = pcall(function()
                    require("jdtls.dap").setup_dap_main_class_configs()
                end)
                if not ok2 then
                    vim.notify(
                        "jdtls: setup_dap_main_class_configs failed: " .. tostring(err),
                        vim.log.levels.WARN
                    )
                end
            end, 4000)
        end
    end,
    settings = {
        java = {
            eclipse = { downloadSources = true },
            maven = { downloadSources = true },
            configuration = {
                runtimes = env.runtimes,
                updateBuildConfiguration = "automatic",
            },
            import = {
                gradle = { enabled = true, wrapper = { enabled = true } },
                maven = { enabled = true },
                exclusions = {
                    "**/node_modules/**",
                    "**/.metadata/**",
                    "**/archetype-resources/**",
                    "**/META-INF/maven/**",
                },
            },
            jdt = { ls = { lombokSupport = { enabled = env.lombok ~= nil } } },
            -- Code lenses fire many requests; enable if you want them
            implementationsCodeLens = { enabled = false },
            referencesCodeLens = { enabled = false },
            references = { includeDecompiledSources = true },
            signatureHelp = { enabled = true, description = { enabled = true } },
            contentProvider = { preferred = "fernflower" },
            symbols = { includeSourceMethodDeclarations = true },
            format = { enabled = true, onType = { enabled = false } },
            saveActions = { organizeImports = false },
            errors = { incompleteClasspath = { severity = "warning" } },
            completion = {
                enabled = true,
                guessMethodArguments = true,
                favoriteStaticMembers = {
                    "org.hamcrest.MatcherAssert.assertThat",
                    "org.hamcrest.Matchers.*",
                    "org.hamcrest.CoreMatchers.*",
                    "org.junit.jupiter.api.Assertions.*",
                    "java.util.Objects.requireNonNull",
                    "java.util.Objects.requireNonNullElse",
                    "org.mockito.Mockito.*",
                    "org.mockito.ArgumentMatchers.*",
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
                organizeImports = { starThreshold = 9999, staticStarThreshold = 9999 },
            },
            codeGeneration = {
                toString = {
                    template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
                },
                hashCodeEquals = { useJava7Objects = true },
                useBlocks = true,
                generateComments = false,
            },
        },
    },
    flags = {
        debounce_text_changes = 150,
        allow_incremental_sync = true,
    },
}

jdtls.start_or_attach(config)
