vim.schedule(function()
	local ok, jdtls = pcall(require, "jdtls")
	if not ok then return end

	local fn, find_root = vim.fn, require("jdtls.setup").find_root

	local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }
	local project_name = fn.fnamemodify(find_root(root_markers), ":p:h:t")
	local workspace_dir = fn.stdpath("cache") .. "/site/java/workspace-root/" .. project_name

	if fn.isdirectory(workspace_dir) == 0 then fn.mkdir(workspace_dir, "p") end

	-- get the mason install path
	local install_path = require("mason-registry").get_package("jdtls"):get_install_path()

	local os = vim.loop.os_uname().sysname

	if os == "Linux" then
		os = "linux"
	elseif os == "Darwin" then
		os = "mac"
	elseif os == "Windows" then
		os = "win"
	end

	local get_java_path = function()
		return fn.filereadable("/usr/lib/jvm/java-17-openjdk/bin/java") == 1
				and "/usr/lib/jvm/java-17-openjdk/bin/java"
			or fn.exepath("java")
	end

	local config = {
		cmd = {
			get_java_path(),
			-- "/usr/lib/jvm/java-17-openjdk/bin/java", -- or '/path/to/java17_or_newer/bin/java'
			"-Declipse.application=org.eclipse.jdt.ls.core.id1",
			"-Dosgi.bundles.defaultStartLevel=4",
			"-Declipse.product=org.eclipse.jdt.ls.core.product",
			"-Dlog.protocol=true",
			"-Dlog.level=ALL",
			"-javaagent:" .. install_path .. "/lombok.jar",
			"-Xmx1g",
			"--add-modules=ALL-SYSTEM",
			"--add-opens",
			"java.base/java.util=ALL-UNNAMED",
			"--add-opens",
			"java.base/java.lang=ALL-UNNAMED",
			"-jar",
			fn.glob(install_path .. "/plugins/org.eclipse.equinox.launcher_*.jar", true, true)[1],
			"-configuration",
			install_path .. "/config_" .. os,
			"-data",
			workspace_dir,
		},
		capabilities = require("plugins.configs.lsp.default").capabilities,
		on_attach = require("plugins.configs.lsp.default").on_attach,
		root_dir = find_root(root_markers),
		settings = {
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
			signatureHelp = { enabled = true },
			extendedClientCapabilities = jdtls.extendedClientCapabilities,
			sources = {
				organizeImports = {
					starThreshold = 9999,
					staticStarThreshold = 9999,
				},
			},
			java = {
				configuration = {
					runtimes = {
						{
							name = "JavaSE-11",
							path = "/usr/lib/jvm/java-11-openjdk/",
						},
						{
							name = "JavaSE-17",
							path = "/usr/lib/jvm/java-17-openjdk/",
						},
					},
				},
			},
		},
		flags = {
			allow_incremental_sync = true,
		},
		init_options = {
			bundles = {
				fn.glob(
					fn.stdpath("data")
						.. "/mason/"
						.. "packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar",
					true,
					true
				)[1],
			},
		},
	}

	jdtls.start_or_attach(config)
end)
