local status_ok, wilder = pcall(require, "wilder")
if not status_ok then return end

local colors = require("ui.colors")

wilder.setup {
	modes = { ":", "/", "?" },
	next_key = "<Tab>",
	previous_key = "<S-Tab>",
	enable_cmdline_enter = 1,
}

local set_option = wilder.set_option
local popupmenu_devicons = wilder.popupmenu_devicons
local popupmenu_renderer = wilder.popupmenu_renderer
local popupmenu_palette_theme = wilder.popupmenu_palette_theme

set_option("use_python_remote_plugin", 0)
set_option("pipeline", {
	wilder.branch(
		wilder.cmdline_pipeline {
			fuzzy = 1,
			fuzzy_filter = wilder.lua_fzy_filter(),
		},
		wilder.vim_search_pipeline()
	),
})

local general_style = {
	border = "single", -- 'single' | 'double' | 'rounded' | 'solid'
	max_height = "80%",
	min_height = 0, -- set to the same as 'max_height' for a fixed height window
	prompt_position = "top", -- 'top' or 'bottom'
	reverse = 0, -- 1 to reverse
	left = { " ", popupmenu_devicons() },
	highlighter = { wilder.lua_fzy_highlighter() },
	highlights = {
		accent = wilder.make_hl("WilderAccent", "Pmenu", {
			{ a = 1 },
			{ a = 1 },
			{ foreground = colors.pink },
		}),
	},
}

local change_left_icons = function(styles, left)
	styles.left = left
	return styles
end

set_option(
	"renderer",
	wilder.renderer_mux {
		[":"] = popupmenu_renderer(
			popupmenu_palette_theme(change_left_icons(general_style, { " ", "  ", popupmenu_devicons() }))
		),
		["/"] = popupmenu_renderer(
			popupmenu_palette_theme(change_left_icons(general_style, { " ", "  ", popupmenu_devicons() }))
		),
		["?"] = popupmenu_renderer(
			popupmenu_palette_theme(change_left_icons(general_style, { " ", "  ", popupmenu_devicons() }))
		),
	}
)
