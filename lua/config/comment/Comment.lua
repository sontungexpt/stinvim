local options = {
	padding = true, ---Add a space b/w comment and the line
	ignore = "^$",
	toggler = {
		line = "gcc",
		block = "gbc",
	},
	opleader = {
		line = "gc",
		block = "gb",
	},
	extra = {
		above = "gcO",
		below = "gco",
		eol = "gcA",
	},
	mappings = {
		basic = true,
		extra = true,
	},
	pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
}

return options
