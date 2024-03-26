local options = {
	icons = {
		expanded = "▾",
		collapsed = "▸",
	},
	mappings = {
		-- Use a table to apply multiple mappings
		expand = { "<CR>", "<2-LeftMouse>" },
		open = "o",
		remove = "d",
		edit = "e",
		repl = "r",
		toggle = "t",
	},
	floating = {
		max_height = 0.8,
		max_width = 0.8,
		border = "single", -- "single", "double" or "rounded"
		mappings = {
			close = { "q", "<Esc>" },
		},
	},
	windows = {
		indent = 1,
	},
}

return options
