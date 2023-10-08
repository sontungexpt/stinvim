local options = {
	char = "│",
	show_current_context = true,
	show_first_indent_level = true,
	use_treesitter = true,
	indentLine_enabled = 1,
	show_trailing_blankline_indent = false,
	filetype_exclude = {
		"help",
		"terminal",
		"lazy",
		"lspinfo",
		"TelescopePrompt",
		"TelescopeResults",
		"mason",
		"NvimTree",
		"dashboard",
		"Trouble",
		"",
	},
	buftype_exclude = {
		"terminal",
	},
}

return options
