local vim = vim
local api, fn = vim.api, vim.fn
local cmd, autocmd = api.nvim_command, api.nvim_create_autocmd

local group = api.nvim_create_augroup("__core_autocmd__", { clear = true })

local config_dir = fn.stdpath("config")
autocmd("VimEnter", {
	group = group,
	pattern = config_dir .. "/**",
	command = "cd " .. config_dir,
	desc = "Auto change directory to config folder - support for nvimconfig alias",
})

autocmd({ "VimEnter", "VimLeave" }, {
	group = group,
	command = "runtime! plugin/rplugin.vim | silent! UpdateRemotePlugins",
	desc = "Update remote plugins",
})


autocmd("BufWritePre", {
	group = group,
	desc = "Remove trailing whitespace and create parent directory if not exists",
	callback = function(event)
	    -- Trailing whitespace
		api.nvim_buf_call(event.buf, function()
			cmd([[silent! keeppatterns %s/\s\+$//e]])
		end)

		-- Make parent directory if not exists
		if event.match:match("^%w%w+:[\\/][\\/]") then
			return
		end
		local file = vim.uv.fs_realpath(event.match) or event.match
		vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})


autocmd("BufEnter", {
	group = group,
	desc = "Do filetype specific work",
	callback = function(args)
	    local bufnr  = args.buf

	    -- delay a little to ensure the buffer and filetype are fully loaded before processing
		vim.defer_fn(function()
            if not api.nvim_buf_is_valid(bufnr) or not api.nvim_buf_is_loaded(bufnr) then
				return
			end
			local filetype = api.nvim_get_option_value("filetype", { buf = bufnr })

			--- @type table<string, string|function>
            local tasks = {
                help = "wincmd L", -- Open help in vertical split
				qf = "setlocal nobuflisted", -- Don't show quickfix in buffer list
				man = "setlocal nobuflisted",

				-- Disable diagnostic for .env files
				sh = function()
                    if args.file:match("%.env$") then
                        vim.diagnostic.enable(false, { bufnr = bufnr })
                    end
				end,

				-- Fix conceallevel for json files
				json = "setlocal conceallevel=0",
                jsonc = "setlocal conceallevel=0",
                json5 = "setlocal conceallevel=0",
			}

			local task = tasks[filetype]
			local task_type = type(task)
			if task_type == "string" then
				cmd(task)
			elseif task_type == "function" then
				task()
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
	desc = "Highlight yanked text",
  callback = function()
    if vim.fn.has("nvim-0.13") == 1 then
      vim.hl.hl_op()
    else
      (vim.hl or vim.highlight).on_yank()
    end
  end,
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
	desc = "Reload file if changed outside of nvim",
	callback = function()
		if vim.fn.mode() ~= "c" and not vim.fn.bufexists("[Command Line]") then
			cmd("checktime")

			if package.loaded["nvim-tree"] then
				cmd("NvimTreeRefresh")
			end
		end
	end,
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
					local curr_vim_height = vim.o.lines
						- vim.o.cmdheight
						- (vim.o.laststatus ~= 0 and 1 or 0)
						- (vim.o.showtabline ~= 0 and #api.nvim_list_tabpages() > 1 and 1 or 0)

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
