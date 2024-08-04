local autocmd = vim.api.nvim_create_autocmd

vim.schedule(function() -- any maps should work after neovim open
	local uv = vim.uv or vim.loop
	local api = vim.api
	local map = require("utils.mapper").map

	-- Remap for dealing with word wrap
	map({ "n", "x" }, "k", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', 7)
	map({ "n", "x" }, "j", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', 7)
	map({ "n", "v" }, "<Up>", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', 7)
	map({ "n", "v" }, "<Down>", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', 7)

	-- When you press i, automatically indent to the appropriate position
	-- map("n", "i", [[strlen(getline('.')) == 0 ? '_cc' : 'i']], 7)
	map("n", "i", function()
		if not api.nvim_get_option_value("buftype", { buf = 0 }) and api.nvim_get_current_line() == "" then
			local modified = api.nvim_get_option_value("modified", { buf = 0 })
			api.nvim_input(api.nvim_replace_termcodes("_cc", true, true, true))
			if not modified then vim.defer_fn(function() api.nvim_set_option_value("modified", false, { buf = 0 }) end, 1) end
		else
			api.nvim_command("startinsert")
		end
	end)

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

	-- Better escape by jj
	do
		local waiting = false
		local first_pressed_time = 0
		local modified = false

		map({ "i", "c", "t" }, "j", function()
			local mode = api.nvim_get_mode().mode
			local now = uv.now()
			if not waiting then
				waiting = true
				first_pressed_time = now
			elseif now - first_pressed_time < vim.o.timeoutlen then -- waiting
				waiting = false
				if mode == "c" then
					api.nvim_input("<esc>")
					return ""
				elseif mode == "t" then
					return [[<bs><C-\><C-n>]]
				end
				api.nvim_feedkeys(api.nvim_replace_termcodes("<bs><esc>", true, true, true), "n", false)
				if not modified then
					vim.defer_fn(function() api.nvim_set_option_value("modified", false, { buf = 0 }) end, 1)
				end
				return ""
			else -- waiting
				first_pressed_time = now -- new waiting
			end

			if mode == "c" then
				api.nvim_feedkeys("j", "n", true)
				return ""
			end

			modified = api.nvim_get_option_value("modified", { buf = 0 })
			return "j"
		end, 7)
	end

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
	map({ "n", "v" }, "Q", function()
		local buf = api.nvim_get_current_buf()
		if api.nvim_buf_is_valid(buf) and api.nvim_get_option_value("modified", { buf = buf }) then
			require("utils.notify").warn("Buffer is modified, please save it first.")
		else
			api.nvim_buf_delete(buf, {})
		end
	end)

	--Clean searching
	map({ "n", "v" }, "C", "<cmd>noh<cr>:set ignorecase<cr>")

	--Resize Buffer
	map("n", "<A-l>", function() require("utils.window").increase_current_win_width(1) end)
	map("n", "<A-h>", function() require("utils.window").decrease_current_win_width(-1) end)

	map("n", "<A-k>", function() require("utils.window").decrease_current_win_height(1) end)
	map("n", "<A-j>", function() require("utils.window").increase_current_win_height(-1) end)

	--Make all windows (almost) equally high and wide
	map("n", "=", "<C-W>=")

	--Change the layout to horizontal
	map("n", "gv", "<C-w>t<C-w>H", "Change the layout to vertical")

	--Change the layout to vertical
	map("n", "gh", "<C-w>t<C-w>K", "Change the layout to horizontally")

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

	autocmd("TermOpen", {
		callback = function(args)
			local bufnr = args.buf

			-- local map = require("utils.mapper").map
			local close_buf = function() api.nvim_buf_delete(bufnr, { force = true }) end
			local map1 = function(mode, key, map_to) map(mode, key, map_to, { buffer = bufnr }) end

			map1("n", "q", close_buf)
			map1("n", "Q", close_buf)
			map1({ "n", "t" }, "<C-q>", close_buf)
			map1({ "n", "t" }, "<A-q>", close_buf)

			map1("n", "i", "<cmd>startinsert<CR>")

			map1("t", "<esc>", [[<C-\><C-n>]])

			map1("t", "<C-h>", [[<Cmd>wincmd h<CR>]])
			map1("t", "<C-j>", [[<Cmd>wincmd j<CR>]])
			map1("t", "<C-k>", [[<Cmd>wincmd k<CR>]])
			map1("t", "<C-l>", [[<Cmd>wincmd l<CR>]])
			map1("t", "<C-w>", [[<C-\><C-n><C-w>]])
		end,
	})

	autocmd("CmdlineEnter", {
		once = true,
		desc = "Make autoclose brackets, quotes in command mode",
		callback = function()
			-- local map = require("utils.mapper").map
			local bracket_pairs = {
				{ "(", ")" },
				{ "[", "]" },
				{ "{", "}" },
				{ "<", ">" },
				{ "'", "'" },
				{ '"', '"' },
				{ "`", "`" },
			}

			local feedks = api.nvim_feedkeys
			local replace_termcodes = api.nvim_replace_termcodes

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
end)

autocmd({ "BufWinEnter", "CmdwinEnter" }, {
	desc = "Make q close special buffers",
	callback = function(args)
		local buftype = vim.api.nvim_get_option_value("buftype", { buf = args.buf })
		if args.event == "BufWinEnter" and not vim.list_contains({ "help", "nofile", "quickfix" }, buftype) then return end
		require("utils.mapper").map("n", "q", "<cmd>close<cr>", { buffer = args.buf })
	end,
})
