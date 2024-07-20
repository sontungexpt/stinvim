local no_seps = require("configs.lualine.seps").no_seps
local colors = require("ui.colors")

local M = {}
M.value = {
	"location",
	padding = 1,
	separator = no_seps,
	color = { bg = colors.lualine_bg, fg = colors.fg },
}

M.progress = {
	function()
		local current_line = vim.fn.line(".")
		local total_lines = vim.fn.line("$")
		local chars = { "_", "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" }
		local line_ratio = current_line / total_lines
		local index = math.ceil(line_ratio * #chars)
		return chars[index]
	end,
	padding = 0,
	color = { bg = colors.lualine_bg, fg = colors.orange },
}

return M
