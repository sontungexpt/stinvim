local map = require("utils.mapper").map
local map_by_autocmd = require("utils.mapper").map_by_autocmd

-- Remap for dealing with word wrap
map({ "n", "x" }, "k", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', 5)
map({ "n", "x" }, "j", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', 5)
map({ "n", "v" }, "<Up>", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', 5)
map({ "n", "v" }, "<Down>", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', 5)

-- same with P key
-- map("x", "p", 'p:let @+=@0<CR>:let @"=@0<CR>')

-- Indent lines with tab in visual mode
map("v", "<Tab>", ">gv")
map("v", "<S-Tab>", "<gv")

--Back to normal mode
map({ "i", "c" }, "jj", "<esc>", 2)

--Back to insert mode
map("v", "i", "<esc>i")

--Save file as the traditional way
map({ "n", "i", "v", "c" }, "<C-s>", "<esc>:w<cr>", 2)

--ctrl a to selected all text in file
map({ "n", "i", "v" }, "<C-a>", "<esc>ggVG")

--The arrow keys in the insert mode
map("i", "<C-j>", "<Down>")
map("i", "<C-k>", "<Up>")
map("i", "<C-h>", "<Left>")
map("i", "<C-l>", "<Right>")

--Change the buffer
map("n", "]b", ":bnext<cr>")
map("n", "[b", ":bNext<cr>")

--Go to the current path
map({ "n", "v" }, "cd", "<esc>:cd %:p:h<cr>:pwd<cr>", 3)

--Close Buffer
map({ "n", "v" }, "Q", "<esc>:bd<cr>")

--Clean searching
map({ "n", "v" }, "C", "<esc>:noh<cr>:set ignorecase<cr>")

--Resize Buffer
map("n", "<A-j>", ":resize +1<cr>")
map("n", "<A-k>", ":resize -1<cr>")
map("n", "<A-l>", ":vertical resize -1<cr>")
map("n", "<A-h>", ":vertical resize +1<cr>")

--Make all windows (almost) equally high and wide
map("n", "=", "<C-W>=")

--Change the layout to horizohkkntal
map("n", "gv", "<C-w>t<C-w>H")

--Change the layout to vertical
map("n", "gh", "<C-w>t<C-w>K")

-- Split horizontally
map("n", "<A-s>", ":split<CR>", { desc = "Split Down" })

-- Split vertically
map("n", "<A-v>", ":vsplit<CR>", { desc = "Split Right" })

--Move between windows
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

--Swap up one row
map("n", "<A-Up>", ":m .-2<CR>==")
map("v", "<A-Up>", ":m '<-2<CR>gv=gv")

--Swap down one row
map("n", "<A-Down>", ":m .+1<CR>==")
map("v", "<A-Down>", ":m '>+1<CR>gv=gv")

map_by_autocmd("BufWinEnter", {
	desc = "Make q close help, man, quickfix, dap floats",
	callback = function(args)
		local buftype = vim.api.nvim_get_option_value("buftype", { buf = args.buf })
		if vim.tbl_contains({ "help", "nofile", "quickfix" }, buftype) then
			map("n", "q", "<cmd>close<cr>", { buffer = args.buf, nowait = true })
		end
	end,
})

map_by_autocmd("CmdwinEnter", {
	desc = "Make q close command history (q: and q?)",
	command = "nnoremap <silent><buffer><nowait> q :close<CR>",
})
