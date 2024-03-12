local api = vim.api
local autocmd = api.nvim_create_autocmd
local group = api.nvim_create_augroup("STINVIM_CORE_AUTOFILETYPE", { clear = true })

autocmd("BufReadPre", {
	group = group,
	pattern = { "*.json" },
	command = "set filetype=jsonc",
	desc = "Enable syntax for .json files",
})

autocmd("BufReadPre", {
	group = group,
	pattern = { "*.rasi" },
	command = "set filetype=rasi",
	desc = "Enable syntax for .rasi files",
})

autocmd("BufReadPre", {
	group = group,
	pattern = "*.html",
	command = "set filetype=html",
	desc = "Enable syntax for .html files",
})
