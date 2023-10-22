local autocmd = vim.api.nvim_create_autocmd

autocmd({ "BufEnter" }, {
	pattern = { "*.zsh" },
	command = "set filetype=sh",
	desc = "Enable syntax for .zsh files",
})
