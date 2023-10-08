local status_ok, dap = pcall(require, "dap")
if not status_ok then return end

local path_helpers = require("plugins.configs.dap.paths")
local colors = require("core.global-configs").ui.colors

vim.fn.sign_define("DapBreakpoint", { text = " ", texthl = "DapBreakpoint" })
vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = colors.red })
vim.fn.sign_define("DapStopped", { text = "󱞪 ", texthl = "DapStopped" })
vim.api.nvim_set_hl(0, "DapStopped", { fg = colors.green })

dap.adapters.codelldb = {
	type = "server",
	host = "127.0.0.1",
	port = 13000,
	executable = {
		-- CHANGE THIS to your path!
		command = path_helpers.get_adapter_mason_path("codelldb"),
		args = { "--port", 13000 },
	},
}

dap.configurations.cpp = {
	{
		name = "Launch file",
		type = "codelldb",
		request = "launch",
		program = function()
			return vim.fn.input("path to executable: ", vim.fn.getcwd() .. "/bin/program", "file")
		end,
		cwd = "${workspaceFolder}",
		stopOnEntry = false,
		args = {},
	},
}
dap.configurations.c = dap.configurations.cpp

dap.configurations.rust = {
	{
		type = "codelldb",
		name = "Debug Rust",
		request = "launch",
		program = function() return path_helpers.get_rust_debug_filepath() end,
		cwd = "${workspaceFolder}",
		stopOnEntry = false,
	},
}
