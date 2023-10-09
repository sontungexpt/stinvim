local colors = require("core.global-configs").ui.colors

local M = {}

M.branch = {
	"branch",
	icon = " ",
	color = { fg = colors.pink, bg = colors.lualine_bg },
	padding = { left = 1, right = 1 },
}

M.diff = {
	"diff",
	colored = true,
	diff_color = {
		added = "DiagnosticSignInfo", -- Changes the diff's added color
		modified = "DiagnosticSignWarn", -- Changes the diff's modified color
		removed = "DiagnosticSignError", -- Changes the diff's removed color you
	},
	symbols = { added = " ", modified = " ", removed = " " },
	color = { bg = colors.lualine_bg },
}

return M
