local autocmd = vim.api.nvim_create_autocmd

autocmd({ "BufReadPre" }, {
	pattern = { "*.json" },
	command = "set filetype=jsonc",
	desc = "Enable syntax for .json files",
})

autocmd({ "BufReadPre" }, {
	pattern = { "*.rasi" },
	command = "set filetype=rasi",
	desc = "Enable syntax for .rasi files",
})

autocmd({ "BufReadPre" }, {
	pattern = "*.html",
	command = "set filetype=html",
	desc = "Enable syntax for .html files",
})
