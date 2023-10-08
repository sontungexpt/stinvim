require("core")

-- Install lazy neovim if not installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
	require("utils.bootstrap").lazy(lazypath)
end

vim.opt.rtp:prepend(lazypath)

require("plugins")
