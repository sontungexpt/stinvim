local api = vim.api
local autocmd = api.nvim_create_autocmd

local group = api.nvim_create_augroup("STINVIM_CORE_NVIMMAP", { clear = true })

local map = require("utils.mapper").map

-- Remap for dealing with word wrap
map({ "n", "x" }, "k", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', 7)
map({ "n", "x" }, "j", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', 7)
map({ "n", "v" }, "<Up>", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', 7)
map({ "n", "v" }, "<Down>", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', 7)

-- When you press i, automatically indent to the appropriate position
map("n", "i", [[strlen(getline('.')) == 0 ? '_cc' : 'i']], 7)

-- inspect colors
map("n", "<M-C>", "<cmd>Inspect<cr>")

-- Delete empty lines without writing to registers
map("n", "dd", [[match(getline('.'), '^\s*$') != -1 ? '"_dd' : "dd"]], 7)

map("n", "x", [[col('.') == 1 && match(getline('.'), '^\s*$') != -1 ? '"_dd$' : '"_x']], 7)
map("n", "X", [[col('.') == 1 && match(getline('.'), '^\s*$') != -1 ? '"_dd$' : '"_X']], 7)

map("x", "P", "p")
map("x", "p", 'p:let @+=@0<CR>:let @"=@0<CR>')

-- Indent lines with tab in visual mode
map("x", "<Tab>", ">gv|")
map("x", "<S-Tab>", "<gv")
map("n", "<Tab>", ">>_")
map("n", "<S-Tab>", "<<_")

--Back to normal mode
map({ "i", "c" }, "jj", "<esc>", 2)

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
map("n", "<A-j>", "<cmd>resize +1<cr>")
map("n", "<A-k>", "<cmd>resize -1<cr>")
map("n", "<A-l>", "<cmd>vertical resize -1<cr>")
map("n", "<A-h>", "<cmd>vertical resize +1<cr>")

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

autocmd("CmdlineEnter", {
	once = true,
	group = group,
	desc = "Make autoclose brackets, quotes in command mode",
	callback = function(args)
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

autocmd("BufWinEnter", {
	desc = "Make q close help, man, quickfix, dap floats",
	group = group,
	callback = function(args)
		local buftype = api.nvim_get_option_value("buftype", { buf = args.buf })
		if vim.tbl_contains({ "help", "nofile", "quickfix" }, buftype) then
			map("n", "q", "<cmd>close<cr>", { buffer = args.buf, nowait = true })
		end
	end,
})

autocmd("CmdwinEnter", {
	desc = "Make q close command history (q: and q?)",
	group = group,
	command = "nnoremap <silent><buffer><nowait> q :close<CR>",
})
