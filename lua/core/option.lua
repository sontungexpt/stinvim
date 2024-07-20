local vim = vim
local opt, o, g, fn = vim.opt, vim.o, vim.g, vim.fn

-- Disable all providers by default, If we need a provider we can enable it by comment the line
g.loaded_node_provider = 0
g.loaded_perl_provider = 0
g.loaded_python3_provider = 0
g.loaded_ruby_provider = 0

-- Uncomment the following lines to use a ruby and python provider
-- g.ruby_host_prog = "~/.rbenv/versions/3.2.2/bin/neovim-ruby-host"
-- g.python3_host_prog = "~/.venv/bin/python3"

-- File to identify project root
g.stinvim_root_markers = {
	".git",
	"package.json", -- npm
	"Cargo.toml", -- rust
	"stylua.toml", -- lua
	"lazy-lock.json", -- nvim config
	"build.zig", -- zig
	"gradlew", -- java
	"mvnw", -- java
}

g.stinvim_plugin_extension_dir = fn.stdpath("config") .. "/lua/extension"

-- disable netrw for nvimtree
g.loaded_netrw = 1
g.loaded_netrwPlugin = 1

g.skip_ts_context_commentstring_module = true

-- cmp
o.completeopt = "menu,menuone,noselect"

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
o.fillchars = "eob: ,fold: ,foldopen:,foldsep: ,foldclose:"

-- Text width and wrap
o.wrap = false
opt.whichwrap:append("<>[]hl")
o.linebreak = true
o.formatexpr = "v:lua.require'conform'.formatexpr()"
o.textwidth = 100

--Line number
o.number = true
o.relativenumber = false
-- o.numberwidth = 2
-- o.cmdheight = 1 -- default

--Encoding
o.encoding = "utf-8"
o.mouse = fn.isdirectory("/system") == 1 and "v" or "a" -- Enable mouse support on android system
o.mousemoveevent = true

-- o.incsearch = true -- default
-- o.hlsearch = true -- default

--Tabs & indentation
o.tabstop = 2
o.softtabstop = 2
o.shiftwidth = 2
o.expandtab = true
-- o.autoindent = true -- default
o.smartindent = true
-- o.smarttab = true -- default
-- o.backspace = "indent,eol,start" -- default

--Undo file
o.undofile = true

--Update time
o.updatetime = 300 --default 4000ms
o.timeoutlen = 500 --default 1000ms (Shorten key timeout length a little bit for which-key)

--No backup files
o.swapfile = false
o.backup = false
o.writebackup = false

--Search settings
o.ignorecase = true
--o.smartcase = true

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
o.clipboard = "unnamedplus"

--Split window
o.splitbelow = true
o.splitright = true
o.winminwidth = 5

o.wildignore =
	"*.pyc,*.o,*.class,*.obj,*.svn,*.swp,*.swo,*.exe,*.dll,*.so,*.dylib,*.jar,*.zip,*.tar.gz,*.tar.bz2,*.rar,*.tar.xz,*.tar.zst,*.tar.lz,*.hg,*.DS_Store,*.min.*,node_modules"
