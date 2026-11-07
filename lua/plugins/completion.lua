-- ------------------------------------------------- Completion ---------------------------------------------------
-- Autocompletion and IntelliSense plugins.
-- Mission: Provide smart code completion as you type (sources, keymap, fuzzy matching).
return {
	{
		"saghen/blink.cmp",
		version = "1.*",
		dependencies = { "rafamadriz/friendly-snippets" },
		event = { "InsertEnter", "CmdlineEnter" },
		---@module 'blink.cmp'
		---@type blink.cmp.Config
		opts = {
			-- Keymap configuration
			keymap = require("core.keymaps").blink_cmp,

			-- Completion configuration
			completion = {
				keyword = { range = "full" },
				trigger = { prefetch_on_insert = true },
				menu = {
					-- auto_show = function(ctx) return ctx.mode ~= "default" end,
					border = "single",
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
				documentation = {
					window = {
						border = "single",
					},
				},
			},

			-- Sources configuration
			sources = {
				providers = {
					lsp = {
						max_items = 50,
					},
					path = {
						score_offset = 3,
						opts = {
							trailing_slash = false,
							label_trailing_slash = true,
							show_hidden_files_by_default = true,
							get_cwd = function() return vim.fn.getcwd() end,
						},
					},
					buffer = {
						max_items = 5,
						min_keyword_length = 3,
						score_offset = -3,
						opts = {
							get_bufnrs = function() return vim.api.nvim_list_bufs() end,
						},
					},
				},
			},

			-- Fuzzy matching
			fuzzy = {
				max_typos = function(keyword) return math.floor(#keyword / 4) end,
				sorts = { "score", "sort_text" },
			},
		},
	},
}
