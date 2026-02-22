local fn = vim.fn

local dap = require("dap")

local icons = require("ui.icons")

fn.sign_define("DapBreakpoint", {
	text = icons.DapBreakpoint,
	numhl = "DapBreakpoint",
	texthl = "DapBreakpoint",
})

fn.sign_define("DapStopped", {
	text = icons.DapStopped,
	numhl = "DapStopped",
	texthl = "DapStopped",
})

local ok, dapui = pcall(require, "dapui")
if ok then
	dap.listeners.before.attach.dapui_config = function() dapui.open() end
	dap.listeners.before.launch.dapui_config = function() dapui.open() end

	dap.listeners.after.event_terminated.dapui_config = function()
		require("dap.repl").close()
		dapui.close()
	end
	dap.listeners.before.event_exited.dapui_config = function()
		require("dap.repl").close()
		dapui.close()
	end
end

dap.adapters.codelldb = {
	type = "server",
	host = "127.0.0.1",
	port = 13000,
	executable = {
		-- CHANGE THIS to your path!
		command = vim.fn.exepath("codelldb"),
		args = { "--port", 13000 },
	},
}

dap.configurations.cpp = {
	{
		name = "Launch file",
		type = "codelldb",
		request = "launch",
		program = function() return fn.input("path to executable: ", fn.getcwd() .. "/bin/program", "file") end,
		cwd = "${workspaceFolder}",
		stopOnEntry = false,
		args = {},
	},
}
dap.configurations.c = dap.configurations.cpp

dap.adapters.nlua = function(callback, config)
	callback {
		type = "server",
		host = config.host or "127.0.0.1",
		port = config.port or 8086,
	}
end

dap.configurations.lua = {
	{
		name = "Launch file",
		type = "nlua",
		request = "attach",
		-- cwd = "${workspaceFolder}",
		stopOnEntry = false,
		args = {},
	},
}
