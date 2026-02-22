---@type blink.cmp.Config
local options = {
	-- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
	-- 'super-tab' for mappings similar to vscode (tab to accept)
	-- 'enter' for enter to accept
	-- 'none' for no mappings
	--
	-- All presets have the following mappings:
	-- C-space: Open menu or open docs if already open
	-- C-n/C-p or Up/Down: Select next/previous item
	-- C-e: Hide menu
	-- C-k: Toggle signature help (if signature.enabled = true)
	--
	-- See :h blink-cmp-config-keymap for defining your own keymap
	keymap = {
		-- preset = "default",
		preset = "enter",

		["<C-k>"] = { "select_prev", "fallback" },
		["<C-j>"] = { "select_next", "fallback" },

		-- -- disable a keymap from the preset
		-- ["<C-e>"] = false, -- or {}

		-- -- show with a list of providers
		-- ["<C-space>"] = { function(cmp) cmp.show { providers = { "snippets" } } end },
	},

	appearance = {
		-- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
		-- Adjusts spacing to ensure icons are aligned
		-- nerd_font_variant = "mono",
		nerd_font_variant = "normal",
	},

	-- (Default) Only show the documentation popup when manually triggered
	completion = {
		documentation = {
			auto_show = true,
		},
		menu = {
			-- auto_show = function(ctx) return ctx.mode ~= "default" end,
			draw = {
				components = {
					-- customize the drawing of kind icons
					kind_icon = {
						text = function(ctx)
							-- default kind icon
							local icon = ctx.kind_icon
							-- if LSP source, check for color derived from documentation
							if ctx.item.source_name == "LSP" then
								local ok, nvim_highlight_colors = pcall(require, "nvim-highlight-colors")
								if ok then
									local color_item = nvim_highlight_colors.format(ctx.item.documentation, { kind = ctx.kind })
									if color_item and color_item.abbr ~= "" then icon = color_item.abbr end
								end
							end
							return icon .. ctx.icon_gap
						end,
						highlight = function(ctx)
							-- default highlight group
							local highlight = "BlinkCmpKind" .. ctx.kind
							-- if LSP source, check for color derived from documentation
							if ctx.item.source_name == "LSP" then
								local ok, nvim_highlight_colors = pcall(require, "nvim-highlight-colors")
								if ok then
									local color_item = nvim_highlight_colors.format(ctx.item.documentation, { kind = ctx.kind })
									if color_item and color_item.abbr_hl_group then highlight = color_item.abbr_hl_group end
								end
							end
							return highlight
						end,
					},
				},
			},
		},
		-- ghost_text = { enabled = true },
	},

	-- Default list of enabled providers defined so that you can extend it
	-- elsewhere in your config, without redefining it, due to `opts_extend`
	sources = {
		default = { "lsp", "path", "snippets", "buffer" },
	},

	-- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
	-- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
	-- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
	--
	-- See the fuzzy documentation for more information
	fuzzy = { implementation = "prefer_rust_with_warning" },

	signature = { enabled = true },
}

return options
