local options = {
	indent = {
		char = "│",
	},
	exclude = {
		filetypes = { "help", "alpha", "dashboard", "Trouble", "lazy", "NvimTree", "mason" },
		buftypes = { "terminal" },
	},
	whitespace = {
		remove_blankline_trail = true,
	},
}

return options
