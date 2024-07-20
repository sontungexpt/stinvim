local options = {
	ensure_installed = "all",
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
