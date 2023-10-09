local colors = require("core.global-configs").ui.colors
local no_seps = require("core.global-configs").ui.lualine.no_seps

local M = {}

M.value = {
	function()
		if vim.o.columns > 70 then
			return "" .. vim.api.nvim_buf_get_option(0, "shiftwidth")
		end
		return ""
	end,
	padding = 1,
	separator = no_seps,
	color = { bg = colors.lualine_bg, fg = colors.fg },
}

M.icon = {
	function()
		if vim.o.columns > 70 then
			return "Tab" .. ""
		end
		return ""
	end,

	padding = 1,
	separator = no_seps,
	color = { bg = colors.blue, fg = colors.black },
}

return M
