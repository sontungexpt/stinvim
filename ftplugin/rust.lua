vim.g.rustaceanvim = {
	-- Plugin configuration
	-- tools = {},
	--
	-- LSP configuration
	server = {
		on_attach = function(client, bufnr)
			require("config.lsp.default").on_attach(client, bufnr)
			-- you can also put keymaps in here
		end,
		-- default_settings = {
		-- 	-- rust-analyzer language server configuration
		-- 	["rust-analyzer"] = {},
		-- },
	},
	-- DAP configuration
	-- dap = {},
}
