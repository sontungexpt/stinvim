local require = require

-- core module
require("core.environment")
require("core.option")
require("core.autocmd")
require("core.nvimmap")
require("core.plugmap")

-- user module
require("user.autocmd")

-- Install lazy neovim if not installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
	require("core.bootstrap").lazy(lazypath)
else
	require("core.bootstrap").boot(lazypath)
end
