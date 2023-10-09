local colors = require("core.global-configs").ui.colors
local no_seps = require("core.global-configs").ui.lualine.no_seps

return {
	function()
		return package.loaded["copilot_status"] and require("copilot_status").status_string() or ""
	end,
	cnd = function()
		return package.loaded["copilot_status"] and require("copilot_status").enabled()
	end,
	separator = no_seps,
	color = { bg = colors.lualine_bg, fg = colors.fg },
}
