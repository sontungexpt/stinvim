local autocmd = vim.api.nvim_create_autocmd

autocmd("BufReadPost", {
	pattern = "*.zsh",
	command = "set filetype=sh",
	desc = "Enable syntax for .zsh files",
})
