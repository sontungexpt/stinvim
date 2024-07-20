local options = {
	-- show icons in the signs column
	signs = true,
	-- sign priority
	sign_priority = 8,
	-- keywords recognized as todo comments
	highlight = {
		before = "", -- "fg" or "bg" or empty
		keyword = "wide", -- "fg", "bg", "wide", "wide_bg", "wide_fg" or empty. (wide and wide_bg is the same as bg, but will also highlight surrounding characters, wide_fg acts accordingly but with fg)
		after = "fg", -- "fg" or "bg" or empty
		pattern = [[.*<(KEYWORDS)\s*:]], -- pattern or table of patterns, used for highlighting (vim regex)
		comments_only = true, -- uses treesitter to match keywords in comments only
		exclude = {}, -- list of file types to exclude highlighting
	},
}

return options
