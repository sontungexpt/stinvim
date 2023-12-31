local opts = vim.opt
local cmd = vim.api.nvim_command
local g = vim.g

cmd("filetype plugin on")
cmd("filetype plugin indent on")

--Syntax
cmd("syntax enable")
cmd("syntax on")

-- cmp
opts.completeopt = { "menu", "menuone", "noselect" }

-- disable nvim intro
opts.shortmess:append("sI")

-- disable netrw for nvimtree
g.loaded_netrw = 1
g.loaded_netrwPlugin = 1

g.skip_ts_context_commentstring_module = true

-- Don't show mode since we have a statusline
opts.showmode = require("utils").is_plug_installed("lualine.nvim") and false or true
opts.laststatus = 3

-- fold
opts.foldenable = false -- Don't fold by default
opts.foldcolumn = "0"
opts.foldlevel = 99
opts.foldlevelstart = 99
opts.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]

-- Text width and wrap
opts.wrap = false
opts.whichwrap:append("<>[]hl")
opts.linebreak = true
opts.textwidth = 80

--Line number
opts.number = true
opts.numberwidth = 2
opts.relativenumber = false
opts.cmdheight = 1

-- Ruler
opts.ruler = true

--Encoding
opts.encoding = "utf-8"
opts.mouse = vim.fn.isdirectory("/system") == 1 and "v" or "a" -- Enable mouse support on android system
opts.mousemoveevent = true

opts.incsearch = true
opts.hlsearch = true

--Tabs & indentation
opts.tabstop = 2
opts.softtabstop = 2
opts.shiftwidth = 2
opts.expandtab = true
opts.autoindent = true
opts.smartindent = true
opts.smarttab = true
opts.backspace = "indent,eol,start"
opts.copyindent = true

--Undo file
opts.undofile = true

--Update time
opts.updatetime = 300 --default 4000ms
opts.timeoutlen = 500 --default 1000ms (Shorten key timeout length a little bit for which-key)

--No backup files
opts.swapfile = false
opts.backup = false
opts.writebackup = false

--Search settings
opts.ignorecase = true
--options.smartcase = true

--Cursor line
opts.cursorline = true
opts.cursorcolumn = true

--Appearance
opts.termguicolors = true
cmd([[set t_Co=256]])
opts.background = "dark"
opts.signcolumn = "yes"

--List
opts.list = true
opts.listchars:append {
	-- tab = "▸ ",
	tab = "  ",
	trail = "·",
}

--Clipboard
opts.clipboard:append { "unnamedplus" }
cmd([[set go+=a]])

--Split window
opts.splitbelow = true
opts.splitright = true

opts.wildignore:append {
	"*.pyc",
	"*.o",
	"*.class",
	"*.obj",
	"*.svn",
	"*.swp",
	"*.swo",
	"*.exe",
	"*.dll",
	"*.so",
	"*.dylib",
	"*.jar",
	"*.zip",
	"*.tar.gz",
	"*.tar.bz2",
	"*.rar",
	"*.tar.xz",
	"*.tar.zst",
	"*.tar.lz",
	"*.hg",
	"*.DS_Store",
	"*.min.*",
	"node_modules",
}
