local colors = require("ui.colors")
local no_seps = require("configs.lualine.seps").no_seps
local M = {}

M.type = {
	"filetype",
	icon_only = true,
	colored = true,
	padding = { left = 2, right = 1 },
	color = { bg = colors.lualine_bg },
}

M.name = {
	"filename",
	padding = { right = 2 },
	separator = no_seps,
	color = { bg = colors.lualine_bg, fg = colors.orange, gui = "bold" },
	file_status = true,
	newfile_status = false,
	path = 0,
	symbols = {
		modified = "●",
		readonly = " ",
		unnamed = "",
		newfile = " [New]",
	},
}

return M
