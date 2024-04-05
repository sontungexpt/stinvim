local vim = vim

vim.schedule(function()
	local ok, jdtls = pcall(require, "jdtls")
	if not ok then return end

	local fn, uv, fs = vim.fn, (vim.uv or vim.loop), vim.fs

	local mason_registry_get_package = require("mason-registry").get_package
	local jdtls_path = mason_registry_get_package("jdtls"):get_install_path()

	local jar_path = fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar", true, true)[1]
	if not jar_path then
		require("utils.notify").error("JDTLS not found")
		return
	end

	local jdebug_path = mason_registry_get_package("java-debug-adapter"):get_install_path()
	local jtest_path = mason_registry_get_package("java-test"):get_install_path()

	local uname = uv.os_uname().sysname
	uname = uname == "Linux" and "linux" or uname == "Darwin" and "mac" or "win"

	local root_dir = fs.dirname(fs.find({ ".git", "pom.xml", "build.gradle" }, { upward = true })[1])
	local project_name = fn.fnamemodify(root_dir, ":p:h:t")

	local workspace_dir = fn.stdpath("cache") .. "/site/java/workspace-root/" .. project_name
	if fn.isdirectory(workspace_dir) == 0 then fn.mkdir(workspace_dir, "p") end

	local function java()
		return fn.filereadable("/usr/lib/jvm/java-17-openjdk/bin/java") == 1
				and "/usr/lib/jvm/java-17-openjdk/bin/java"
			or fn.exepath("java")
	end

	local extendedClientCapabilities = jdtls.extendedClientCapabilities
	extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

	local config = {
		cmd = {
			java(),
			"-Declipse.application=org.eclipse.jdt.ls.core.id1",
			"-Dosgi.bundles.defaultStartLevel=4",
			"-Declipse.product=org.eclipse.jdt.ls.core.product",
			"-Dlog.protocol=true",
			"-Dlog.level=ALL",
			"-javaagent:" .. jdtls_path .. "/lombok.jar",
			"-Xmx1g",
			"-Xms512m",
			"-Xmx2048m",
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
		capabilities = require("plugins.configs.lsp.default").capabilities,
		on_attach = function(client, bufnr)
			jdtls.setup_dap { hotcodereplace = "auto" }

			require("jdtls.dap").setup_dap_main_class_configs()
			require("jdtls.setup").add_commands()

			require("plugins.configs.lsp.default").on_attach(client, bufnr)

			require("lspsaga").init_lsp_saga()
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
						url = fn.stdpath("config") .. "/lang_servers/intellij-java-google-style.xml",
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
			debounce_text_changes = 150,
			allow_incremental_sync = true,
		},
		init_options = {
			extendedClientCapabilities = extendedClientCapabilities,
			bundles = vim.list_extend(
				fn.glob(jdebug_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar", true, true),
				fn.glob(jtest_path .. "/extension/server/*.jar", true, true)
			),
		},
	}

	jdtls.start_or_attach(config)
end)
