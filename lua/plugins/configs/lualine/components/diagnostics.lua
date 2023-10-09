local colors = require("ui.colors")

return {
	"diagnostics",
	sources = { "nvim_diagnostic" },
	symbols = {
		error = " ",
		warn = " ",
		hint = "󰌵 ",
		info = " ",
	},
	colored = true,
	diagnostics_color = {

		color_error = { fg = colors.red },
		color_warn = { fg = colors.yellow },
		color_info = { fg = colors.blue },
		color_hint = { fg = colors.green },
	},
	always_visible = false,
	update_in_insert = true,
}
