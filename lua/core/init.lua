local require = require
require("core.provider")
require("core.command")
require("core.option")
require("core.autofiletype")
require("core.autocmd")
require("core.nvimmap")
require("core.plugmap").map_on_startup()

-- add binaries installed by mason.nvim to path
local is_windows = vim.loop.os_uname().sysname == "Windows_NT"
vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin" .. (is_windows and ";" or ":") .. vim.env.PATH
