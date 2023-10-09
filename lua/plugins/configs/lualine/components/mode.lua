local colors = require("core.global-configs").ui.colors
local no_seps = require("core.global-configs").ui.lualine.no_seps

return {
	"mode",
	separator = no_seps,
	icons_enabled = true,
	cond = function()
		return vim.o.columns > 70
	end,
}
