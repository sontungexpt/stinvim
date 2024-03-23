local api = vim.api
local cmd, autocmd = api.nvim_command, api.nvim_create_autocmd

local group = api.nvim_create_augroup("STINVIM_CORE_AUTOCMD", { clear = true })

autocmd({ "VimEnter", "VimLeave" }, {
	pattern = "*",
	group = group,
	command = "runtime! plugin/rplugin.vim | silent! UpdateRemotePlugins",
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

autocmd("BufReadPost", {
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

autocmd({ "InsertEnter", "InsertLeave", "TermEnter", "TermLeave" }, {
	group = group,
	desc = "Auto change search highlight color",
	callback = function(args)
		local maps = {
			InsertEnter = "set nohlsearch",
			InsertLeave = "set hlsearch",
			TermEnter = "set nohlsearch",
			TermLeave = "set hlsearch",
		}
		cmd(maps[args.event])
	end,
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

autocmd({ "VimResized", "WinResized" }, {
	group = group,
	desc = "Preserve window ratios on VimResized",
	callback = function(args)
		local win_ids = api.nvim_list_wins()
		local num_of_wins = #win_ids

		if num_of_wins > 1 then
			local vim_width = api.nvim_get_option("columns")
			if args.event == "VimResized" then
				vim.schedule(function()
					for i = 1, num_of_wins - 1 do
						local id = win_ids[i]
						if api.nvim_win_get_config(id).relative == "" then -- not a floating window
							api.nvim_win_set_width(
								id,
								math.ceil(vim_width * api.nvim_win_get_var(id, "w_ratio")[false])
							)
						end
					end
				end, 0)
			else
				for i = 1, num_of_wins do
					local id = win_ids[i]
					api.nvim_win_set_var(id, "w_ratio", api.nvim_win_get_width(id) / vim_width)
				end
			end
		end
	end,
})

autocmd({ "WinLeave", "WinEnter" }, {
	group = group,
	desc = "Highlight current line and column",
	callback = function(args)
		local maps = {
			WinLeave = "setlocal nocursorline nocursorcolumn",
			WinEnter = "if &buflisted | setlocal cursorline cursorcolumn | else | setlocal cursorline | endif",
		}
		cmd(maps[args.event])
	end,
})

autocmd("BufWritePre", {
	group = group,
	desc = "Create missing directories before writing the buffer",
	command = "silent! call mkdir(expand('%:p:h'), 'p')",
})

autocmd("TermLeave", {
	group = group,
	desc = "Refresh nvim-tree when terminal is closed",
	command = "lua if package.loaded['nvim-tree'] then vim.api.nvim_command('NvimTreeRefresh') end",
})
