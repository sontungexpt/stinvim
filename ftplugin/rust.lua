-- https://github.com/mrcjkb/rustaceanvim/blob/master/lua/rustaceanvim/config/internal.lua
--
local executors = require("rustaceanvim.executors")
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

	tools = {
		--- how to execute terminal commands
		--- options right now: termopen / quickfix / toggleterm / vimux
		executor = executors.toggleterm,
		hover_actions = {
			--- whether to replace Neovim's built-in `vim.lsp.buf.hover`.
			---@type boolean
			replace_builtin_hover = false,
		},
	},
	-- DAP configuration
	-- dap = {},
}
