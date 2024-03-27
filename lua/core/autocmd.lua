local api = vim.api
local cmd, autocmd = api.nvim_command, api.nvim_create_autocmd

local group = api.nvim_create_augroup("STINVIM_CORE_AUTOCMD", { clear = true })

autocmd({ "VimEnter", "VimLeave" }, {
	group = group,
	command = "runtime! plugin/rplugin.vim | silent! UpdateRemotePlugins",
	desc = "Update remote plugins",
})

autocmd("FileType", {
	group = group,
	pattern = "help",
	command = "wincmd L",
	desc = "Open help in vertical split",
})

autocmd("FileType", {
	group = group,
	pattern = "qf",
	command = "set nobuflisted",
	desc = "Don't list quickfix buffers",
})

autocmd("BufReadPost", {
	group = group,
	pattern = "*.env",
	callback = function(args) vim.diagnostic.disable(args.buf) end,
	desc = "Disable diagnostic for .env files",
})

autocmd({ "WinLeave", "WinEnter" }, {
	group = group,
	desc = "Highlight current line and column",
	callback = function(args)
		cmd(({
			WinLeave = "setlocal nocursorline nocursorcolumn",
			WinEnter = "if &buflisted | setlocal cursorline cursorcolumn | else | setlocal cursorline | endif",
		})[args.event])
	end,
})

autocmd("TextYankPost", {
	group = group,
	command = "silent! lua vim.highlight.on_yank({higroup='IncSearch', timeout=120})",
	desc = "Highlight yanked text",
})

autocmd("BufWritePre", {
	group = group,
	desc = "Create missing directories before writing the buffer",
	command = "silent! call mkdir(expand('%:p:h'), 'p')",
})

autocmd("BufWritePre", {
	group = group,
	command = ":%s/\\s\\+$//e",
	desc = "Remove whitespace on save",
})

autocmd("ModeChanged", {
	group = group,
	command = "if mode() == 'v' | set relativenumber | else | set norelativenumber | endif",
	desc = "Move to relative line number when in visual mode",
})

autocmd("MenuPopup", {
	group = group,
	once = true,
	desc = "Customize right click contextual menu.",
	callback = function()
		-- Disable right click message
		cmd([[aunmenu PopUp.How-to\ disable\ mouse]])
		-- cmd([[aunmenu PopUp.-1-]]) -- You can remode a separator like this.
		cmd([[menu PopUp.󰏘\ Inspect\ Color <cmd>:Inspect<CR>]])
		cmd([[menu PopUp.\ Start\ \Debugger <cmd>:DapContinue<CR>]])
		cmd([[menu PopUp.\ Toggle\ \Breakpoint <cmd>:lua require('dap').toggle_breakpoint()<CR>]])
	end,
})

autocmd({ "InsertEnter", "InsertLeave", "TermEnter", "TermLeave" }, {
	group = group,
	desc = "Auto change search highlight color",
	callback = function(args)
		cmd(({
			InsertEnter = "set nohlsearch",
			InsertLeave = "set hlsearch",
			TermEnter = "set nohlsearch",
			TermLeave = "set hlsearch",
		})[args.event])
	end,
})

-- https://unix.stackexchange.com/questions/149209/refresh-changed-content-of-file-opened-in-vim/383044#383044
-- https://vi.stackexchange.com/questions/13692/prevent-focusgained-autocmd-running-in-command-line-editing-mode
autocmd({ "FocusGained", "TermResponse", "TermLeave" }, {
	group = group,
	command = [[silent! if mode() != 'c' && !bufexists("[Command Line]") | checktime | endif | lua if package.loaded['nvim-tree'] then vim.api.nvim_command('NvimTreeRefresh') end]],
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

autocmd({ "VimResized", "WinResized", "WinNew" }, {
	group = group,
	desc = "Preserve window ratios on VimResized",
	callback = function(args)
		vim.schedule(function()
			local win_ids = api.nvim_list_wins()
			if #win_ids > 1 then
				local vim_width = api.nvim_get_option("columns")
				local vim_height = api.nvim_get_option("lines")

				if args.event == "VimResized" then
					vim.o.cmdheight = vim.o.cmdheight or 1
					for index, id in ipairs(win_ids) do
						local ratio_x = vim.w[id].ratio_x
						if type(ratio_x) == "table" then
							api.nvim_win_set_width(id, math.floor(vim_width / ratio_x[2] * ratio_x[1]))
						end
						local ratio_y = vim.w[id].ratio_y
						if type(ratio_y) == "table" then
							api.nvim_win_set_height(id, math.floor(vim_height / ratio_y[2] * ratio_y[1]))
						end
					end
					vim.o.cmdheight = vim.o.cmdheight or 1
				else
					for index, id in ipairs(win_ids) do
						api.nvim_win_set_var(id, "ratio_x", { api.nvim_win_get_width(id), vim_width })
						api.nvim_win_set_var(id, "ratio_y", { api.nvim_win_get_height(id), vim_height })
					end
				end
			end
		end, 0)
	end,
})
