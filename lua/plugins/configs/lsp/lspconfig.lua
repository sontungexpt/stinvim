local lspconfig = require("lspconfig")
local on_attach = require("plugins.configs.lsp.default").on_attach
local capabilities = require("plugins.configs.lsp.default").capabilities

local lsp_servers = {

	-- python
	{
		name = "pyright",
	},

	-- bash
	{
		name = "bashls",
	},

	-- cpp
	{
		name = "clangd",
		config = {
			on_attach = function(client, bufnr)
				on_attach(client, bufnr)
				client.server_capabilities.semanticTokensProvider = nil
			end,
		},
	},

	{
		name = "cmake",
	},

	-- zig
	{
		name = "zls",
	},

	-- dev
	{
		name = "cssls",
	},
	{
		name = "eslint",
		config = {
			on_attach = function(client, bufnr)
				on_attach(client, bufnr)
				client.resolved_capabilities.document_formatting = true
			end,
		},
	},
	{
		name = "svelte",
	},
	{
		name = "html",
	},
	{
		name = "jsonls",
	},
	{
		name = "tailwindcss",
	},
	{
		name = "tsserver",
	},
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
				"jsx",
				"tsx",
				"typescriptreact",
				"javascriptreact",
				"vue",
				"vue-html",
			},
		},
	},

	--rust
	{
		name = "rust_analyzer",
		config = {
			cmd = {
				"rustup",
				"run",
				"stable",
				"rust-analyzer",
			},
		},
	},

	-- lua
	{
		name = "lua_ls",
		config = {
			settings = {
				Lua = {
					diagnostics = {
						globals = { "vim" },
					},
					workspace = {
						library = {
							[vim.fn.expand("$VIMRUNTIME/lua")] = true,
							[vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
							[vim.fn.stdpath("data") .. "/lazy/lazy.nvim/lua/lazy"] = true,
						},
						maxPreload = 100000,
						preloadFileSize = 10000,
					},
				},
			},
		},
	},
}

for _, server in ipairs(lsp_servers) do
	local config = server.config or {}
	config.on_attach = config.on_attach or on_attach
	config.capabilities = config.capabilities or capabilities
	lspconfig[server.name].setup(config)
end
