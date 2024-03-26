local fn, api = vim.fn, vim.api

local dap = require("dap")

local icons = require("ui.icons")
local colors = require("ui.colors")

fn.sign_define("DapBreakpoint", {
	text = icons.DapBreakpoint,
	numhl = "DapBreakpoint",
	texthl = "DapBreakpoint",
})
api.nvim_set_hl(0, "DapBreakpoint", {
	fg = colors.red,
})
fn.sign_define("DapStopped", {
	text = icons.DapStopped,
	numhl = "DapStopped",
	texthl = "DapStopped",
})
api.nvim_set_hl(0, "DapStopped", {
	fg = colors.green,
})

local ok, dapui = pcall(require, "dapui")
if ok then
	dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
	dap.listeners.after.disconnect["dapui_config"] = function()
		require("dap.repl").close()
		dapui.close()
	end
	dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
	dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end
end

local function get_bin_path(adapter_name, custom_path)
	return require("mason-registry").get_package(adapter_name):get_install_path()
		.. "/"
		.. (custom_path or adapter_name)
end

dap.adapters.codelldb = {
	type = "server",
	host = "127.0.0.1",
	port = 13000,
	executable = {
		-- CHANGE THIS to your path!
		command = get_bin_path("codelldb"),
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

dap.configurations.rust = {
	{
		type = "codelldb",
		name = "Debug Rust",
		request = "launch",
		program = function()
			local root = require("utils").find_root()
			return root and (root .. "/target/debug/" .. fn.fnamemodify(root, ":p:h:t"))
				or fn.input("path to executable: ", fn.getcwd(), "file")
		end,
		cwd = "${workspaceFolder}",
		stopOnEntry = false,
	},
}
