local autocmd = vim.api.nvim_create_autocmd

autocmd({ "BufEnter" }, {
	pattern = { "*.json" },
	command = "set filetype=jsonc",
	desc = "Enable syntax for .json files",
})

autocmd({ "BufEnter" }, {
	pattern = { "*.rasi" },
	command = "set filetype=rasi",
	desc = "Enable syntax for .rasi files",
})

autocmd({ "BufEnter" }, {
	pattern = "*.html",
	command = "set filetype=html",
	desc = "Enable syntax for .html files",
})
