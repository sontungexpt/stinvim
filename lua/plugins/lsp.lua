local vim = vim
local lsp, fn = vim.lsp, vim.fn
-- ---------------------------------------------------- LSP ----------------------------------------------------
-- Language Server Protocol plugins.
-- Mission: LSP configuration, server management (mason), language-specific servers, and LSP keymaps.

return {
	{
		"neovim/nvim-lspconfig",
		cmd = { "LspInfo" },
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			servers = {
				-- Official JetBrains Kotlin LSP (currently Alpha).
				{ name = "kotlin_lsp" },

				-- Python
				{ name = "basedpyright" },
				{
					name = "ruff",
					config = {
						-- Let basedpyright handle hover/type information.
						on_attach = function(client) client.server_capabilities.hoverProvider = false end,
					},
				},

				-- go
				{ name = "gopls" },

				-- bash
				{ name = "bashls" },

				-- cpp
				{ name = "clangd" },

				-- CMake
				{ name = "cmake" },

				-- Zig
				{ name = "zls" },

				-- Biome: JS / TS / JSON / CSS diagnostics and code actions.
				{ name = "biome" },

				-- ESLint: project-specific JavaScript / TypeScript linting.
				{ name = "eslint" },

				-- CSS
				{ name = "cssls" },

				-- HTML
				{ name = "html" },

				-- JSON
				{ name = "jsonls" },

				-- Vue 3
				{ name = "vue_ls" },

				-- Tailwind CSS
				{ name = "tailwindcss" },

				-- Emmet
				{
					name = "emmet_ls",
					config = {
						filetypes = {
							"html",
							"css",
							"sass",
							"scss",
							"less",
							"javascript",
							"typescript",
							"javascriptreact",
							"typescriptreact",
							"vue",
							"vue-html",
						},
					},
				},

				-- TOML
				{ name = "tombi" },

				-- Markdown
				{ name = "marksman" },

				-- YAML
				{ name = "yamlls" },

				-- lua
				{
					name = "lua_ls",
					config = {
						settings = {
							Lua = {
								runtime = {
									version = "LuaJIT",
								},
								diagnostics = {
									globals = { "vim" },
								},
								workspace = {
									library = {
										[fn.expand("$VIMRUNTIME/lua")] = true,
										[fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
										[fn.stdpath("data") .. "/lazy/lazy.nvim/lua/lazy"] = true,
										["${3rd}/luv/library"] = true,
									},
									maxPreload = 100000,
									preloadFileSize = 10000,
								},
							},
						},
					},
				},
			},
		},
		config = function(_, opts)
			local core_lsp = require("core.lsp")
			--- Diagnostic configuration
			core_lsp.setup_diagnostics()

			--- LSP handlers
			lsp.buf.signature_help {
				border = "single",
				focusable = false,
				relative = "cursor",
			}

			lsp.buf.hover {
				border = "single",
			}

			--- Base capabilities
			local capabilities = core_lsp.make_default_capabilities()
			--- Default config for all servers
			lsp.config("*", {
				capabilities = capabilities,
				on_init = function(client)
					if client:supports_method("textDocument/semanticTokens") then
						client.server_capabilities.semanticTokensProvider = nil
					end
				end,
			})

			--- Apply per-server overrides and enable servers
			-- Neovim automatically merges server config with vim.lsp.config("*", ...)
			-- so we only need to call vim.lsp.config() when there are per-server overrides.
			for _, server in ipairs(opts.servers) do
				if server.config then lsp.config(server.name, server.config) end
				lsp.enable(server.name)
			end
		end,
	},
	{
		"mfussenegger/nvim-jdtls",
		ft = "java",
	},
	{
		"mrcjkb/rustaceanvim",
		ft = "rust",
		-- rustaceanvim manages rust-analyzer itself, do NOT use mason for it
		-- See: https://github.com/mrcjkb/rustaceanvim#important
	},
	{
		"mason-org/mason.nvim",
		build = ":MasonUpdate",
		cmd = { "Mason", "MasonLog", "MasonUpdate", "MasonInstall", "MasonUninstall", "MasonUninstallAll" },
		main = "mason",
		opts = {
			ensure_installed = { "stylua", "shfmt" },
			ui = {
				border = "single",
				icons = {
					package_pending = " ",
					package_installed = " ",
					package_uninstalled = " ",
				},
			},
		},
		config = function(_, opts)
			require("mason").setup(opts)
			local mr = require("mason-registry")
			mr:on("package:install:success", function()
				vim.defer_fn(
					function()
						require("lazy.core.handler.event").trigger {
							event = "FileType",
							buf = vim.api.nvim_get_current_buf(),
						}
					end,
					100
				)
			end)
		end,
	},
	{
		dir = "/home/stilux/Data/workspace/neovim-plugins/mason-scout",
		lazy = false,
		cmd = {
			"MasonScout",
		},
		opts = {}, -- see Configuration section
	},
	-- {
	--   "Saecki/crates.nvim",
	--   ft = { "toml" },
	--   config = function()
	--     require("crates").setup({
	--       lsp = {
	--         enabled = true,
	--         actions = true,
	--         completion = true,
	--         hover = true,
	--       },
	--       popup = {
	--         autofocus = false,
	--       },
	--     })
	--   end,
	-- },
	-- {
	--   "akinsho/flutter-tools.nvim",
	--   ft = "dart",
	--   event = "BufReadPost */pubspec.yaml",
	--   dependencies = {
	--     "nvim-lua/plenary.nvim",
	--     "stevearc/dressing.nvim",
	--   },
	--   main = "flutter-tools",
	--   opts = {
	--     ui = {
	--       border = "single",
	--     },
	--     lsp = {
	--       on_attach = function(client, bufnr) end,
	--     },
	--   },
	-- },
}
