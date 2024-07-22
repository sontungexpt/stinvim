local ok, jdtls = pcall(require, "jdtls")
if not ok then return end

local vim = vim
local fn, fs = vim.fn, vim.fs
local mason_registry_get_package = require("mason-registry").get_package

local jdtls_path = mason_registry_get_package("jdtls"):get_install_path()

local jar_path = fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar", true, true)[1]
if not jar_path then
	require("utils.notify").error("JDTLS not found")
	return
end

local jdebug_path = mason_registry_get_package("java-debug-adapter"):get_install_path()
local jtest_path = mason_registry_get_package("java-test"):get_install_path()

local uname = (vim.uv or vim.loop).os_uname().sysname
uname = uname == "Linux" and "linux" or uname == "Darwin" and "mac" or "win"

local root_dir = fs.root(0, { ".git", "pom.xml", "build.gradle" })
if not root_dir then return end

local project_name = fs.basename(root_dir)

local workspace_dir = fn.stdpath("cache") .. "/site/java/workspace-root/" .. project_name
if fn.isdirectory(workspace_dir) == 0 then fn.mkdir(workspace_dir, "p") end

local function find_java()
	local java_priority_paths = {
		"/usr/lib/jvm/java-17-openjdk/bin/java",
		"/usr/lib/jvm/java-11-openjdk/bin/java",
		"/usr/lib/jvm/java-8-openjdk/bin/java",
	}
	for i, path in ipairs(java_priority_paths) do
		if fn.filereadable(path) == 1 then return path, {
			name = i,
			path = path,
		} end
	end
	local java = fn.exepath("java")
	if java ~= "" then return java, {
		name = 1,
		path = java,
	} end
	return nil, nil
end

local java_path, runtime_paths = find_java()
if not java_path then
	require("utils.notify").error("Java not found")
	return
end

local extendedClientCapabilities = jdtls.extendedClientCapabilities
extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

local config = {
	cmd = {
		java_path,
		"-Declipse.application=org.eclipse.jdt.ls.core.id1",
		"-Dosgi.bundles.defaultStartLevel=4",
		"-Declipse.product=org.eclipse.jdt.ls.core.product",
		"-Dlog.protocol=true",
		"-Dlog.level=ALL",
		"-javaagent:" .. jdtls_path .. "/lombok.jar",
		"-Xmx1g",
		"--add-modules=ALL-SYSTEM",
		"--add-opens",
		"java.base/java.util=ALL-UNNAMED",
		"--add-opens",
		"java.base/java.lang=ALL-UNNAMED",
		"-jar",
		jar_path,
		"-configuration",
		jdtls_path .. "/config_" .. uname,
		"-data",
		workspace_dir,
	},
	capabilities = require("config.lsp.default").capabilities,
	on_attach = function(client, bufnr)
		jdtls.setup_dap { hotcodereplace = "auto" }

		require("jdtls.setup").add_commands()
		require("config.lsp.default").on_attach(client, bufnr)
	end,
	root_dir = root_dir,
	settings = {
		java = {
			eclipse = {
				downloadSources = true,
			},
			maven = {
				downloadSources = true,
			},
			implementationsCodeLens = {
				enabled = true,
			},
			referencesCodeLens = {
				enabled = true,
			},
			references = {
				includeDecompiledSources = true,
			},
			signatureHelp = {
				enabled = true,
			},
			contentProvider = {
				preferred = "fernflower",
			},
			format = {
				enabled = true,
				settings = {
					url = fn.stdpath("config") .. "/lang-servers/intellij-java-google-style.xml",
					profile = "GoogleStyle",
				},
			},
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
				importOrder = {
					"java",
					"javax",
					"com",
					"org",
				},
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
				hashCodeEquals = {
					useJava7Objects = true,
				},
				useBlocks = true,
			},
			configuration = {
				runtimes = runtime_paths,
				-- runtimes = {
				-- 	-- {
				-- 	-- 	name = "JavaSE-11",
				-- 	-- 	path = "/usr/lib/jvm/java-11-openjdk/",
				-- 	-- },
				-- 	{
				-- 		name = "JavaSE-17",
				-- 		path = "/usr/lib/jvm/java-17-openjdk/",
				-- 	},
				-- },
			},
		},
		flags = {
			debounce_text_changes = 150,
			allow_incremental_sync = true,
		},
		init_options = {
			extendedClientCapabilities = extendedClientCapabilities,
			bundles = (jdebug_path ~= "" and jtest_path ~= "" and vim.list_extend(
				fn.glob(jdebug_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar", true, true),
				fn.glob(jtest_path .. "/extension/server/*.jar", true, true)
			)) or nil,
		},
	},
}

jdtls.start_or_attach(config)
