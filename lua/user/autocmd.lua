local api = vim.api
local fn = vim.fn
local autocmd = api.nvim_create_autocmd
local augroup = api.nvim_create_augroup

autocmd({ "VimEnter" }, {
	group = augroup("AutocdConfigFolderRoot", { clear = true }),
	pattern = fn.stdpath("config") .. "/**",
	command = "cd " .. fn.stdpath("config"),
	desc = "Auto change directory to config folder - support for nvimconfig alias",
})

autocmd({ "BufWritePost" }, {
	group = augroup("ScriptBuilder", { clear = true }),
	desc = "Compile scripts in ~/scripts/stilux/systems",
	pattern = { fn.expand("$HOME") .. "/scripts/stilux/systems/*" },
	callback = require("user.utils").compile_stilux_srcipt_file,
})
