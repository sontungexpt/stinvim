local status_ok, lspconfig = pcall(require, "lspconfig")

if not status_ok then return end

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
	},
	{
		name = "cmake",
	},

	-- dev
	{
		name = "cssls",
	},
	{
		name = "eslint",
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
				"typescriptreact",
				"javascriptreact",
				"css",
				"sass",
				"scss",
				"less",
				"javascript",
				"typescript",
				"vue",
				"vue-html",
				"jsx",
				"tsx",
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
	config.on_attach = config.on_attach or require("plugins.configs.lsp.general-confs").on_attach
	config.capabilities = config.capabilities
		or require("plugins.configs.lsp.general-confs").capabilities()
	lspconfig[server.name].setup(config)
end
