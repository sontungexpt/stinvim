local options = {
	-- style = "storm", -- `storm`, `moon`, a darker variant `night` and `day`
	style = "moon", -- `storm`, `moon`, a darker variant `night` and `day`
	light_style = "day",
	transparent = false,
	terminal_colors = true,
	styles = {
		comments = { italic = true },
		keywords = { italic = true },
		functions = {},
		variables = {},
		-- Background styles. Can be "dark", "transparent" or "normal"
		sidebars = "dark", -- "dark", "transparent" or "normal"
		floats = "dark", -- "dark", "transparent" or "normal"
	},
	sidebars = { "qf", "help" },
	day_brightness = 0.4,
	hide_inactive_statusline = false,
	dim_inactive = false, -- dims inactive windows
	lualine_bold = false, -- When `true`, section headers in the lualine theme will be bold
}

return options
