local lspconfig = require("lspconfig")
local default = require("config.lsp.default")
local on_attach = default.on_attach
local capabilities = default.capabilities
local on_init = default.on_init

local lsp_servers = {

	-- python
	{
		name = "pylyzer",
	},

	-- go
	{
		name = "gopls",
	},

	-- bash
	{
		name = "bashls",
	},

	-- cpp
	{
		name = "clangd",
	},

	{
		name = "cmake",
	},

	-- zig
	{
		name = "zls",
	},

	-- web
	{
		name = "biome",
	},
	{
		name = "cssls",
	},
	{
		name = "eslint",
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
		name = "vtsls",
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
	config.on_init = on_init
	config.on_attach = config.on_attach or on_attach
	config.capabilities = config.capabilities or capabilities
	lspconfig[server.name].setup(config)
end
