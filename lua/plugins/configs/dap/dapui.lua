local has_dap, dap = pcall(require, "dap")
if not has_dap then return end

local has_dapui, dapui = pcall(require, "dapui")
if not has_dapui then return end

local has_dap_virtual_text, dap_virtual_text = pcall(require, "nvim-dap-virtual-text")
if not has_dap_virtual_text then return end

local options = {
	icons = { expanded = "▾", collapsed = "▸" },
	mappings = {
		-- Use a table to apply multiple mappings
		expand = { "<CR>", "<2-LeftMouse>" },
		open = "o",
		remove = "d",
		edit = "e",
		repl = "r",
		toggle = "t",
	},
	expand_lines = vim.fn.has("nvim-0.7"),
	layouts = {
		{
			elements = {
				{
					id = "scopes",
					size = 0.25,
				},
				{
					id = "breakpoints",
					size = 0.25,
				},
				{
					id = "stacks",
					size = 0.25,
				},
				{
					id = "watches",
					size = 0.25,
				},
			},
			position = "left",
			size = 40,
		},

		{
			elements = {
				{
					id = "repl",
					size = 0.5,
				},
				{
					id = "console",
					size = 0.5,
				},
			},
			position = "bottom",
			size = 10,
		},
	},
	floating = {
		max_height = nil, -- These can be integers or a float between 0 and 1.
		max_width = nil, -- Floats will be treated as percentage of your screen.
		border = "single", -- Border style. Can be "single", "double" or "rounded"
		mappings = {
			close = { "q", "<Esc>" },
		},
	},
	windows = { indent = 1 },
	render = {
		max_type_length = nil, -- Can be integer or nil.
	},
}

dap.listeners.after.event_initialized["dapui_config"] = function()
	dapui.open()
	dap_virtual_text.refresh()
end

dap.listeners.after.disconnect["dapui_config"] = function()
	require("dap.repl").close()
	dapui.close()
	dap_virtual_text.refresh()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
	dapui.close()
	dap_virtual_text.refresh()
end
dap.listeners.before.event_exited["dapui_config"] = function()
	dapui.close()
	dap_virtual_text.refresh()
end

dapui.setup(options)
