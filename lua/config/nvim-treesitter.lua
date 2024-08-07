-- Check if android or iphone device
local is_mobile = vim.fn.isdirectory("/system") == 1 or vim.fn.isdirectory("/var/mobile")

local options = {
	ensure_installed = not is_mobile and "all",
	ignore_install = {
		"comment", -- i don't need comment url highlight because i use url-open plugin
	},
	highlight = {
		enable = true,
		use_languagetree = true,
		additional_vim_regex_highlighting = false,
		--disable ={"html","css"}
	},
	indent = {
		enable = true,
	},
	additional_vim_regex_highlighting = false,
	autotag = {
		enable = true,
		filetypes = {
			"html",
			"xml",
			"jsx",
			"tsx",
			"javascript",
			"javascriptreact",
			"typescript",
			"typescriptreact",
		},
	},
	autopairs = {
		enable = true,
	},
}

return options
