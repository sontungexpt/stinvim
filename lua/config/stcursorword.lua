local options = {
	max_word_length = 100, -- if cursorword length > max_word_length then not highlight
	min_word_length = 2, -- if cursorword length < min_word_length then not highlight
	excluded = {
		filetypes = {},
		buftypes = {
			"terminal",
		},
		file_patterns = {},
	},
	highlight = {
		underline = true,
		fg = nil,
		bg = nil,
	},
}

return options
