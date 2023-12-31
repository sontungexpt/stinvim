local api = vim.api
local fn = vim.fn
local cmd = api.nvim_command
local autocmd = api.nvim_create_autocmd
local group = api.nvim_create_augroup("STINVIM_CORE_AUTOCMD", { clear = true })

autocmd({ "VimEnter", "VimLeave" }, {
	pattern = "*",
	group = group,
	command = "runtime! plugin/rplugin.vim",
	desc = "Update remote plugins",
})

autocmd({ "VimEnter", "VimLeave" }, {
	pattern = "*",
	group = group,
	command = "silent! UpdateRemotePlugins",
	desc = "Update remote plugins",
})

autocmd("TextYankPost", {
	group = group,
	command = "silent! lua vim.highlight.on_yank({higroup='IncSearch', timeout=120})",
	desc = "Highlight yanked text",
})

autocmd("FileType", {
	group = group,
	pattern = "qf",
	command = "set nobuflisted",
	desc = "Don't list quickfix buffers",
})

autocmd("BufWritePre", {
	group = group,
	pattern = "*",
	command = ":%s/\\s\\+$//e",
	desc = "Remove whitespace on save",
})

autocmd("ModeChanged", {
	group = group,
	pattern = "*",
	command = "if mode() == 'v' | set relativenumber | else | set norelativenumber | endif",
	desc = "Move to relative line number when in visual mode",
})

autocmd({ "BufReadPre" }, {
	group = group,
	pattern = "*.env",
	callback = function(args) vim.diagnostic.disable(args.buf) end,
	desc = "Disable diagnostic for .env files",
})

autocmd("VimEnter", {
	group = group,
	desc = "Customize right click contextual menu.",
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
	group = group,
	desc = "Set no search highlighting when entering insert mode, or terminal",
	command = "set nohlsearch",
})

autocmd({ "InsertLeave", "TermLeave" }, {
	group = group,
	desc = "Set search highlighting when leaving insert mode, or terminal",
	command = "set hlsearch",
})

-- https://unix.stackexchange.com/questions/149209/refresh-changed-content-of-file-opened-in-vim/383044#383044
-- https://vi.stackexchange.com/questions/13692/prevent-focusgained-autocmd-running-in-command-line-editing-mode
autocmd({ "FocusGained", "BufEnter", "TermResponse" }, {
	group = group,
	command = [[silent! if mode() != 'c' && !bufexists("[Command Line]") | checktime | endif]],
	desc = "Reload file if changed outside of nvim",
})

autocmd("BufHidden", {
	desc = "Delete [No Name] buffer when it's hidden",
	group = group,
	callback = function(event)
		if event.file == "" and vim.bo[event.buf].buftype == "" and not vim.bo[event.buf].modified then
			vim.schedule(function() api.nvim_buf_delete(event.buf, { force = true }) end)
		end
	end,
})

autocmd("FileType", {
	pattern = { "help" },
	group = group,
	desc = "Open help in vertical split",
	command = "wincmd L",
})

autocmd("VimResized", {
	group = group,
	desc = "Resize windows on VimResized",
	command = "wincmd =",
})

autocmd("WinLeave", {
	group = group,
	desc = "Disable cursorline, cursorcolumn when leaving window",
	command = "setlocal nocursorline nocursorcolumn",
})

autocmd("WinEnter", {
	group = group,
	desc = "Enable cursorline, cursorcolumn when entering window and buffer is listed in buffer list",
	command = "if &buflisted | setlocal cursorline cursorcolumn | else | setlocal cursorline | endif",
})

autocmd({ "BufWritePre" }, {
	group = group,
	desc = "Create missing directories before writing the buffer",
	command = "silent! call mkdir(expand('%:p:h'), 'p')",
})

autocmd("BufWritePost", {
	group = group,
	desc = "Reload NvimTree after writing the buffer",
	callback = function()
		local bufs = fn.getbufinfo()
		for _, buf in ipairs(bufs) do
			if buf.name:find("NvimTree_") then
				cmd("NvimTreeRefresh")
				break
			end
		end
	end,
})
