local options = {
	ensure_installed = "all",
	ignore_install = {
		"comment", -- i don't need comment url highlight because i use url-open plugin
	},
	highlight = {
		enable = true,
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
	context_commentstring = {
		enable = true,
	},
}

return options
