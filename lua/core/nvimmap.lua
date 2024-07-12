local autocmd = vim.api.nvim_create_autocmd

vim.schedule(function()
	local map = require("utils.mapper").map

	-- Remap for dealing with word wrap
	map({ "n", "x" }, "k", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', 7)
	map({ "n", "x" }, "j", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', 7)
	map({ "n", "v" }, "<Up>", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', 7)
	map({ "n", "v" }, "<Down>", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', 7)

	-- When you press i, automatically indent to the appropriate position
	map("n", "i", [[strlen(getline('.')) == 0 ? '_cc' : 'i']], 7)

	-- Delete empty lines without writing to registers
	map("n", "dd", [[match(getline('.'), '^\s*$') != -1 ? '"_dd' : "dd"]], 7)
	map("n", "dx", "x")

	-- inspect colors
	map("n", "<M-C>", "<cmd>Inspect<cr>")

	-- Delete empty lines without writing to registers
	map("n", "x", [[col('.') == 1 && match(getline('.'), '^\s*$') != -1 ? '"_dd$' : '"_x']], 7)
	map("n", "X", [[col('.') == 1 && match(getline('.'), '^\s*$') != -1 ? '"_dd$' : '"_X']], 7)

	map("x", "P", "p")
	map("x", "p", 'p:let @+=@0<CR>:let @"=@0<CR>')

	-- Indent lines with tab in visual mode
	map("x", "<Tab>", ">gv|")
	map("x", "<S-Tab>", "<gv")
	map("n", "<Tab>", ">>_")
	map("n", "<S-Tab>", "<<_")

	local uv = vim.uv or vim.loop
	local timerj = uv.new_timer()
	local waitj = false
	--Back to normal mode
	map({ "i", "c" }, "j", function()
		timerj:stop()
		if waitj then
			local cursor = vim.api.nvim_win_get_cursor(0)
			local col = cursor[2]

			if col > 0 then
				local line = cursor[1] - 1
				local left_char = vim.api.nvim_buf_get_text(0, line, col - 1, line, col, {})[1]
				if left_char == "j" then
					waitj = false
					return "<bs><esc>"
				end
			end
		end

		timerj:start(
			vim.o.updatetime or 300,
			0,
			vim.schedule_wrap(function()
				waitj = false
				timerj:stop()
			end)
		)
		waitj = true
		return "j"
	end, 7)

	--Save file as the traditional way
	map({ "n", "i", "v", "c" }, "<C-s>", "<cmd>w<cr>", 2)

	--ctrl a to selected all text in file
	map({ "n", "i", "v" }, "<C-a>", "<cmd>normal! ggVG<cr>")

	--The arrow keys in the insert mode
	map("i", "<C-j>", "<Down>")
	map("i", "<C-k>", "<Up>")
	map("i", "<C-h>", "<Left>")
	map("i", "<C-l>", "<Right>")

	--Change the buffer
	map("n", "]b", "<cmd>bnext<cr>")
	map("n", "[b", "<cmd>bNext<cr>")

	--Go to the current path
	map({ "n", "v" }, "cd", "<cmd>cd %:p:h<cr>:pwd<cr>", 3)

	--Close Buffer
	map({ "n", "v" }, "Q", "<cmd>bd<cr>")

	--Clean searching
	map({ "n", "v" }, "C", "<cmd>noh<cr>:set ignorecase<cr>")

	--Resize Buffer
	map("n", "<A-l>", function()
		local winnr = vim.fn.winnr()
		-- local num = vim.api.nvim_win_get_number(0)
		if winnr == vim.fn.winnr("l") then
			return ":vertical resize -1<CR>"
		elseif winnr == vim.fn.winnr("h") then
			return ":vertical resize +1<CR>"
		else
			local vim_center_x = math.floor(vim.api.nvim_get_option("columns") / 2)
			local win_center_x = math.floor(vim.api.nvim_win_get_position(0)[2] + vim.api.nvim_win_get_width(0) / 2)
			if win_center_x < vim_center_x then
				return ":vertical resize +1<CR>"
			else
				return ":wincmd h<CR>|:vertical resize -1<CR>|:wincmd l<CR>"
			end
		end
	end, 7)
	map("n", "<A-h>", function()
		local winnr = vim.fn.winnr()
		if winnr == vim.fn.winnr("l") then
			return ":vertical resize +1<CR>"
		elseif winnr == vim.fn.winnr("h") then
			return ":vertical resize -1<CR>"
		else
			local vim_center_x = math.floor(vim.api.nvim_get_option("columns") / 2)
			local win_center_x = math.floor(vim.api.nvim_win_get_position(0)[2] + vim.api.nvim_win_get_width(0) / 2)
			if win_center_x > vim_center_x then
				return ":vertical resize -1<CR>"
			else
				return ":wincmd h<CR>|:vertical resize +1<CR>|:wincmd l<CR>"
			end
		end
	end, 7)
	map("n", "<A-k>", function()
		local winnr = vim.fn.winnr()
		if winnr == vim.fn.winnr("j") then
			return ":resize +1<CR>"
		elseif winnr == vim.fn.winnr("k") then
			return ":resize -1<CR>"
		else
			local vim_center_y = (vim.api.nvim_get_option("lines") - vim.api.nvim_get_option("cmdheight")) / 2
			local win_center_y = math.floor(vim.api.nvim_win_get_position(0)[1] + vim.api.nvim_win_get_height(0) / 2)
			if win_center_y > vim_center_y then
				return ":resize -1<CR>"
			else
				return ":wincmd k<CR>|:resize +1<CR>|:wincmd j<CR>"
			end
		end
	end, 7)
	map("n", "<A-j>", function()
		local winnr = vim.fn.winnr()
		if winnr == vim.fn.winnr("j") then
			return ":resize -1<CR>"
		elseif winnr == vim.fn.winnr("k") then
			return ":resize +1<CR>"
		else
			local vim_center_y = (vim.api.nvim_get_option("lines") - vim.api.nvim_get_option("cmdheight")) / 2
			local win_center_y = math.floor(vim.api.nvim_win_get_position(0)[1] + vim.api.nvim_win_get_height(0) / 2)
			if win_center_y < vim_center_y then
				return ":resize +1<CR>"
			else
				return ":wincmd k<CR>|:resize -1<CR>|:wincmd j<CR>"
			end
		end
	end, 7)

	--Make all windows (almost) equally high and wide
	map("n", "=", "<C-W>=")

	--Change the layout to horizontal
	map("n", "gv", "<C-w>t<C-w>H")

	--Change the layout to vertical
	map("n", "gh", "<C-w>t<C-w>K")

	-- Split horizontally
	map("n", "<A-s>", "<cmd>split<CR>")

	-- Split vertically
	map("n", "<A-v>", "<cmd>vsplit<CR>")

	--Move between windows
	map("n", "<C-h>", "<C-w>h")
	map("n", "<C-j>", "<C-w>j")
	map("n", "<C-k>", "<C-w>k")
	map("n", "<C-l>", "<C-w>l")

	--Swap up one row
	map("n", "<A-Up>", "<cmd>m .-2<CR>==")
	map("v", "<A-Up>", "<cmd>m '<-2<CR>gv=gv")

	--Swap down one row
	map("n", "<A-Down>", "<cmd>m .+1<CR>==")
	map("v", "<A-Down>", "<cmd>m '>+1<CR>gv=gv")
end)

autocmd("CmdlineEnter", {
	once = true,
	desc = "Make autoclose brackets, quotes in command mode",
	callback = function()
		local map = require("utils.mapper").map
		local bracket_pairs = {
			{ "(", ")" },
			{ "[", "]" },
			{ "{", "}" },
			{ "<", ">" },
			{ "'", "'" },
			{ '"', '"' },
			{ "`", "`" },
		}

		local feedks = vim.api.nvim_feedkeys
		local replace_termcodes = vim.api.nvim_replace_termcodes

		for _, pair in ipairs(bracket_pairs) do
			map(
				"c",
				pair[1],
				function() feedks(replace_termcodes(pair[1] .. pair[2] .. "<left>", true, true, true), "n", true) end,
				7
			)
		end
	end,
})

autocmd({ "BufWinEnter", "CmdwinEnter" }, {
	desc = "Make q close special buffers",
	callback = function(args)
		local buftype = vim.api.nvim_get_option_value("buftype", { buf = args.buf })
		if args.event == "BufWinEnter" and not vim.list_contains({ "help", "nofile", "quickfix" }, buftype) then return end
		require("utils.mapper").map("n", "q", "<cmd>close<cr>", { buffer = args.buf })
	end,
})
