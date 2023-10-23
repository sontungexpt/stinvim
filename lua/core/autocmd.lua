local api = vim.api
local fn = vim.fn
local cmd = api.nvim_command
local autocmd = api.nvim_create_autocmd
local augroup = api.nvim_create_augroup

autocmd({ "VimEnter", "VimLeave" }, {
	pattern = "*",
	command = "runtime! plugin/rplugin.vim",
	desc = "Update remote plugins",
})

autocmd({ "VimEnter", "VimLeave" }, {
	pattern = "*",
	command = "silent! UpdateRemotePlugins",
	desc = "Update remote plugins",
})

autocmd("TextYankPost", {
	command = "silent! lua vim.highlight.on_yank({higroup='IncSearch', timeout=120})",
	desc = "Highlight yanked text",
})

autocmd("FileType", {
	pattern = "qf",
	command = "set nobuflisted",
	desc = "Don't list quickfix buffers",
})

autocmd("BufWritePre", {
	pattern = "*",
	command = ":%s/\\s\\+$//e",
	desc = "Remove whitespace on save",
})

autocmd("ModeChanged", {
	pattern = "*",
	command = "if mode() == 'v' | set relativenumber | else | set norelativenumber | endif",
	desc = "Move to relative line number when in visual mode",
})

autocmd({ "BufReadPre" }, {
	pattern = "*.env",
	callback = function(args) vim.diagnostic.disable(args.buf) end,
	desc = "Disable diagnostic for .env files",
})

autocmd("VimEnter", {
	desc = "Customize right click contextual menu.",
	group = augroup("ContextualMenu", { clear = true }),
	callback = function()
		-- Disable right click message
		cmd([[aunmenu PopUp.How-to\ disable\ mouse]])
		-- cmd [[aunmenu PopUp.-1-]] -- You can remode a separator like this.
		cmd([[menu PopUp.Toggle\ \Breakpoint <cmd>:lua require('dap').toggle_breakpoint()<CR>]])
		cmd([[menu PopUp.Start\ \Debugger <cmd>:DapContinue<CR>]])
	end,
})

-- Toggle search highlighting on insert mode
autocmd({ "InsertEnter", "TermEnter" }, {
	desc = "Set no search highlighting when entering insert mode, or terminal",
	command = "set nohlsearch",
})

autocmd({ "InsertLeave", "TermLeave" }, {
	desc = "Set search highlighting when leaving insert mode, or terminal",
	command = "set hlsearch",
})

-- https://unix.stackexchange.com/questions/149209/refresh-changed-content-of-file-opened-in-vim/383044#383044
-- https://vi.stackexchange.com/questions/13692/prevent-focusgained-autocmd-running-in-command-line-editing-mode
autocmd({ "FocusGained", "BufEnter", "TermResponse" }, {
	command = [[silent! if mode() != 'c' && !bufexists("[Command Line]") | checktime | endif]],
	desc = "Reload file if changed outside of nvim",
})

autocmd("BufHidden", {
	desc = "Delete [No Name] buffer when it's hidden",
	callback = function(event)
		if event.file == "" and vim.bo[event.buf].buftype == "" and not vim.bo[event.buf].modified then
			vim.schedule(function() api.nvim_buf_delete(event.buf, { force = true }) end)
		end
	end,
})

autocmd("FileType", {
	pattern = { "help" },
	desc = "Open help in vertical split",
	command = "wincmd L",
})

autocmd("VimResized", {
	desc = "Resize windows on VimResized",
	command = "wincmd =",
})

autocmd("WinLeave", {
	desc = "Disable cursorline, cursorcolumn when leaving window",
	command = "setlocal nocursorline nocursorcolumn",
})

autocmd("WinEnter", {
	desc = "Enable cursorline, cursorcolumn when entering window and buffer is listed in buffer list",
	command = "if &buflisted | setlocal cursorline cursorcolumn | else | setlocal cursorline | endif",
})

autocmd({ "BufWritePre" }, {
	desc = "Create missing directories before writing the buffer",
	command = "silent! call mkdir(expand('%:p:h'), 'p')",
})
