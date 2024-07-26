local api, type = vim.api, type
local cmd, autocmd = api.nvim_command, api.nvim_create_autocmd

local group = api.nvim_create_augroup("STINVIM_CORE_AUTOCMD", { clear = true })

autocmd({ "VimEnter", "VimLeave" }, {
	group = group,
	command = "runtime! plugin/rplugin.vim | silent! UpdateRemotePlugins",
	desc = "Update remote plugins",
})

autocmd("BufWritePre", {
	group = group,
	command = "silent! %s/\\s\\+$//e | silent! call mkdir(expand('%:p:h'), 'p')",
	desc = "Remove trailing whitespace and create parent directory if not exists",
})

autocmd("BufEnter", {
	group = group,
	desc = "Do filetype specific work",
	callback = function(args)
		vim.defer_fn(function()
			local bufnr = api.nvim_get_current_buf()
			local work = ({
				help = "wincmd L", -- Open help in vertical split
				qf = "set nobuflisted", -- Don't show quickfix in buffer list
				sh = function()
					if args.file:match("%.env$") then vim.diagnostic.enable(false, { bufnr = bufnr }) end
				end, -- Disable diagnostic for .env files
			})[vim.bo[bufnr].filetype]

			if type(work) == "string" then
				cmd(work)
			elseif type(work) == "function" then
				work()
			end
		end, 3)
	end,
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

autocmd("ModeChanged", {
	group = group,
	desc = "Move to relative line number when in visual mode",
	callback = function(args)
		local newmode = args.match:match(":(.*)")
		local visual_modes = {
			["v"] = true,
			["V"] = true,
			[""] = true,
		}
		if visual_modes[newmode] then
			cmd("set relativenumber")
		else
			cmd("set norelativenumber")
		end
	end,
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
			api.nvim_buf_delete(event.buf, { force = true })
		end
	end,
})

do
	local vim_resized_trigger = false
	autocmd({ "VimResized", "WinScrolled" }, {
		group = group,
		desc = "Preserve window ratios on VimResized",
		callback = function(args)
			vim.schedule(function()
				local win_ids = api.nvim_tabpage_list_wins(0)
				local num_wins = #win_ids

				if num_wins > 1 then
					local curr_vim_width = vim.o.columns
					local curr_vim_height = vim.o.lines - vim.o.cmdheight

					if args.event == "VimResized" then
						vim_resized_trigger = true
						for i = 1, num_wins, 1 do
							local id = win_ids[i]
							local last_widths, last_heights = vim.w[id].last_widths, vim.w[id].last_heights
							local ceil_or_floor = i % 2 == 1 and math.ceil or math.floor
							if type(last_widths) == "table" then
								api.nvim_win_set_width(id, ceil_or_floor(curr_vim_width / last_widths[2] * last_widths[1]))
							end
							if type(last_heights) == "table" then
								api.nvim_win_set_height(id, ceil_or_floor(curr_vim_height / last_heights[2] * last_heights[1]))
							end
						end
					elseif not vim_resized_trigger then
						for i = 1, num_wins, 1 do
							local id = win_ids[i]
							api.nvim_win_set_var(id, "last_widths", { api.nvim_win_get_width(id), curr_vim_width })
							api.nvim_win_set_var(id, "last_heights", { api.nvim_win_get_height(id), curr_vim_height })
						end
					else
						vim_resized_trigger = false
					end
				end
			end)
		end,
	})
end
