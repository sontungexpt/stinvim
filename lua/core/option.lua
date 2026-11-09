local vim = vim
local opt, o, g = vim.opt, vim.o, vim.g

-- Disable all providers by default
g.loaded_node_provider = 0
g.loaded_perl_provider = 0
g.loaded_python3_provider = 0
g.loaded_ruby_provider = 0

-- Uncomment the following lines to use a ruby and python provider
-- g.ruby_host_prog = "~/.rbenv/versions/3.2.2/bin/neovim-ruby-host"
-- g.python3_host_prog = "~/.venv/bin/python3"

-- disable netrw for nvimtree
g.loaded_netrw = 1
g.loaded_netrwPlugin = 1
g.loaded_netrwSettings = 1
g.loaded_netrwFileHandlers = 1
g.loaded_netrw_gitignore = 1

-- o.conceallevel = 2 -- Hide * markup for bold and italic, but not markers with substitutions

o.confirm = true -- Confirm to save changes before exiting modified buffer

-- cmp
o.completeopt = "menu,menuone,noselect"

-- Virtual edit
o.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode

-- Spell checking
opt.spelllang = { "en" }

-- disable nvim intro
opt.shortmess:append("I")

-- Don't show mode since we have a statusline
o.showmode = false
o.laststatus = 3

-- fold
o.foldenable = false -- Don't fold by default
o.foldcolumn = "0"
o.foldlevel = 99
o.foldlevelstart = 99
opt.fillchars = {
  foldopen = "",
  foldclose = "",
  fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}


-- Text width and wrap
o.wrap = false
opt.whichwrap:append("<>[]hl")
o.linebreak = true
o.textwidth = 100

--Line number
o.number = true
o.relativenumber = false
-- o.numberwidth = 2
-- o.cmdheight = 1 -- default

--Tabs & indentation
o.tabstop = 2
o.softtabstop = 2
o.shiftwidth = 2
o.expandtab = true -- Use spaces instead of tabs
o.smartcase = true -- Don't ignore case with capitals
o.smartindent = true
o.smoothscroll = true

--Undo file
o.undofile = true
o.undolevels = 10000

--Update time
o.updatetime = 300 -- default 4000ms
o.timeoutlen = 500 -- default 1000ms

--No backup files
o.swapfile = false
o.backup = false
o.writebackup = false

--Search settings
o.ignorecase = true

--Cursor line
o.cursorline = true
o.cursorcolumn = true

--Appearance
o.termguicolors = true
-- o.background = "dark" -- default
o.signcolumn = "yes"

--List
o.list = true
-- tab = "▸ ",
o.listchars = "tab:  ,trail:·"

--Clipboard
o.clipboard = vim.env.SSH_CONNECTION and "" or "unnamedplus" -- Sync with system clipboard

--Split window
o.splitkeep = "screen"
o.splitbelow = true
o.splitright = true
o.winminwidth = 5

o.wildignore =
	"*.pyc,*.pyo,*.o,*.obj,*.class,*.exe,*.dll,*.so,*.dylib,*.jar,*.swp,*.swo,*.DS_Store,.git,.svn,.hg,node_modules"
