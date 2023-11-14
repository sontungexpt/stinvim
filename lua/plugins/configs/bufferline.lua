local colors = require("ui.colors")

local options = {
	options = {
		-- set to "tabs" to only show tabpages instead
		mode = "buffers",
		-- | "ordinal" | "buffer_id" | "both" | function({ ordinal, id, lower, raise }): string,
		numbers = "none",
		close_command = "bdelete %d",
		right_mouse_command = function(bufnr)
			vim.api.nvim_command("vsplit")
			vim.api.nvim_command("buffer " .. bufnr)
		end,
		left_mouse_command = "buffer %d",
		middle_mouse_command = "bdelete %d",
		indicator = {
			-- icon = "▍",
			icon = " ",
			style = "icon",
		},
		icon_close_tab = "",
		icon_close_tab_modified = "●",
		icon_pinned = "車",
		close_icon = "",
		buffer_close_icon = "",
		modified_icon = "● ",
		left_trunc_marker = "",
		right_trunc_marker = "",
		truncate_names = true, -- whether or not tab names should be truncated
		max_name_length = 30,
		max_prefix_length = 13,
		tab_size = 23,
		diagnostics = "nvim_lsp",
		diagnostics_update_in_insert = true,
		-- The diagnostics indicator can be set to nil to keep the buffer name highlight but delete the highlighting
		-- diagnostics_indicator = function(count, level, diagnostics_dict, context)
		--   if context.buffer:current() then
		--     return ''
		--   end
		--   return ''
		-- end,
		diagnostics_indicator = function(count) return "(" .. count .. ")" end,
		offsets = {
			{
				filetype = "NvimTree",
				-- text = "File Explorer",
				text = "",
				text_align = "center", --"left" | "center" | "right",
				padding = 1,
				-- highlight = "Normal",
				highlight = "TabLine",
				separator = false,
			},
		},
		show_buffer_icons = true,
		show_buffer_close_icons = true,
		show_close_icon = false,
		show_tab_indicators = true,
		persist_buffer_sort = true, -- whether or not custom sorted buffers should persist
		-- separator_style = "thin", -- | "thick" | "thin" | { 'any', 'any' },
		separator_style = { "│", "│" }, -- | "thick" | "thin" | { 'any', 'any' },
		show_current_context = true,
		enforce_regular_tabs = true,
		always_show_bufferline = true,
		hover = {
			enabled = true,
			delay = 0,
			reveal = { "close" },
		},
		sort_by = "insert_after_current",
	},
	highlights = {
		fill = {
			fg = { attribute = "fg", highlight = "TabLine" },
			bg = { attribute = "bg", highlight = "TabLine" },
		},
		background = {
			fg = colors.gray,
			-- fg = { attribute = "fg", highlight = "TabLine" },
			bg = { attribute = "bg", highlight = "TabLine" },
		},
		buffer_visible = {
			fg = { attribute = "fg", highlight = "TabLine" },
			bg = { attribute = "bg", highlight = "TabLine" },
		},
		buffer_selected = {
			fg = { attribute = "fg", highlight = "Normal" },
			bg = { attribute = "bg", highlight = "Normal" },
			bold = true,
			italic = true,
		},
		close_button = {
			fg = { attribute = "fg", highlight = "TabLine" },
			bg = { attribute = "bg", highlight = "TabLine" },
		},
		close_button_visible = {
			fg = { attribute = "fg", highlight = "TabLine" },
			bg = { attribute = "bg", highlight = "TabLine" },
		},
		close_button_selected = {
			fg = { attribute = "fg", highlight = "Normal" },
			bg = { attribute = "bg", highlight = "Normal" },
		},
		tab = {
			fg = { attribute = "fg", highlight = "TabLine" },
			bg = { attribute = "bg", highlight = "TabLine" },
		},
		tab_close = {
			fg = { attribute = "fg", highlight = "LspDiagnosticsDefaultError" },
			bg = { attribute = "bg", highlight = "Normal" },
		},
		tab_selected = {
			fg = { attribute = "fg", highlight = "TabLine" },
			bg = { attribute = "bg", highlight = "TabLine" },
		},
		duplicate_selected = {
			fg = { attribute = "fg", highlight = "TabLine" },
			bg = { attribute = "bg", highlight = "TabLine" },
			bold = true,
			italic = true,
		},
		duplicate_visible = {
			fg = { attribute = "fg", highlight = "TabLine" },
			bg = { attribute = "bg", highlight = "TabLine" },
			bold = true,
			italic = true,
		},
		duplicate = {
			fg = { attribute = "fg", highlight = "TabLine" },
			bg = { attribute = "bg", highlight = "TabLine" },
			bold = true,
			italic = true,
		},
		modified = {
			fg = { attribute = "fg", highlight = "TabLine" },
			bg = { attribute = "bg", highlight = "TabLine" },
		},
		modified_selected = {
			fg = { attribute = "fg", highlight = "Normal" },
			bg = { attribute = "bg", highlight = "Normal" },
		},
		modified_visible = {
			fg = { attribute = "fg", highlight = "TabLine" },
			bg = { attribute = "bg", highlight = "TabLine" },
		},
		separator = {
			fg = { attribute = "fg", highlight = "TabLine" },
			bg = { attribute = "bg", highlight = "TabLine" },
		},
		separator_selected = {
			fg = { attribute = "fg", highlight = "TabLine" },
			bg = { attribute = "bg", highlight = "TabLine" },
		},
		separator_visible = {
			fg = { attribute = "fg", highlight = "TabLine" },
			bg = { attribute = "bg", highlight = "TabLine" },
		},
		indicator_selected = {
			fg = { attribute = "fg", highlight = "LspDiagnosticsDefaultHint" },
			bg = { attribute = "bg", highlight = "Normal" },
		},
		numbers = {
			fg = { attribute = "fg", highlight = "TabLine" },
			bg = { attribute = "bg", highlight = "TabLine" },
		},
		numbers_visible = {
			fg = { attribute = "fg", highlight = "TabLine" },
			bg = { attribute = "bg", highlight = "TabLine" },
		},

		numbers_selected = {
			fg = { attribute = "fg", highlight = "Normal" },
			bg = { attribute = "bg", highlight = "Normal" },
			bold = true,
			italic = true,
		},
		diagnostic = {
			fg = { attribute = "fg", highlight = "TabLine" },
			bg = { attribute = "bg", highlight = "TabLine" },
		},
		diagnostic_visible = {
			fg = { attribute = "fg", highlight = "TabLine" },
			bg = { attribute = "bg", highlight = "TabLine" },
		},
		diagnostic_selected = {
			fg = { attribute = "fg", highlight = "Normal" },
			bg = { attribute = "bg", highlight = "Normal" },
			bold = true,
			italic = true,
		},
		hint = {
			fg = { attribute = "fg", highlight = "TabLine" },
			bg = { attribute = "bg", highlight = "TabLine" },
		},
		hint_visible = {
			fg = { attribute = "fg", highlight = "TabLine" },
			bg = { attribute = "bg", highlight = "TabLine" },
		},
		hint_selected = {
			fg = colors.cyan,
			bg = { attribute = "bg", highlight = "Normal" },
			bold = true,
			italic = true,
		},
		hint_diagnostic = {
			fg = colors.cyan,
			bg = { attribute = "bg", highlight = "TabLine" },
		},
		hint_diagnostic_visible = {
			fg = colors.cyan,
			bg = { attribute = "bg", highlight = "TabLine" },
		},
		hint_diagnostic_selected = {
			fg = colors.cyan,
			bg = { attribute = "bg", highlight = "Normal" },
			bold = true,
			italic = true,
		},
		info = {
			fg = { attribute = "fg", highlight = "TabLine" },
			bg = { attribute = "bg", highlight = "TabLine" },
		},
		info_visible = {
			fg = { attribute = "fg", highlight = "TabLine" },
			bg = { attribute = "bg", highlight = "TabLine" },
		},
		info_selected = {
			fg = colors.blue,
			bg = { attribute = "bg", highlight = "Normal" },
			bold = true,
			italic = true,
		},
		info_diagnostic = {
			fg = colors.blue,
			bg = { attribute = "bg", highlight = "TabLine" },
		},
		info_diagnostic_visible = {
			fg = colors.blue,
			bg = { attribute = "bg", highlight = "TabLine" },
		},
		info_diagnostic_selected = {
			fg = colors.blue,
			bg = { attribute = "bg", highlight = "Normal" },
			bold = true,
			italic = true,
		},
		warning = {
			fg = { attribute = "fg", highlight = "TabLine" },
			bg = { attribute = "bg", highlight = "TabLine" },
		},
		warning_visible = {
			fg = { attribute = "fg", highlight = "TabLine" },
			bg = { attribute = "bg", highlight = "TabLine" },
		},
		warning_selected = {
			fg = colors.yellow,
			bg = { attribute = "bg", highlight = "Normal" },
			bold = true,
			italic = true,
		},
		warning_diagnostic = {
			fg = colors.yellow,
			bg = { attribute = "bg", highlight = "TabLine" },
		},
		warning_diagnostic_visible = {
			fg = colors.yellow,
			bg = { attribute = "bg", highlight = "TabLine" },
		},
		warning_diagnostic_selected = {
			fg = colors.yellow,
			bg = { attribute = "bg", highlight = "Normal" },
			bold = true,
			italic = true,
		},
		error = {
			fg = { attribute = "fg", highlight = "TabLine" },
			bg = { attribute = "bg", highlight = "TabLine" },
		},
		error_visible = {
			fg = { attribute = "fg", highlight = "TabLine" },
			bg = { attribute = "bg", highlight = "TabLine" },
		},
		error_selected = {
			fg = colors.red,
			bg = { attribute = "bg", highlight = "Normal" },
			bold = true,
			italic = true,
		},
		error_diagnostic = {
			fg = colors.red,
			bg = { attribute = "bg", highlight = "TabLine" },
		},
		error_diagnostic_visible = {
			fg = colors.red,
			bg = { attribute = "bg", highlight = "TabLine" },
		},
		error_diagnostic_selected = {
			fg = colors.red,
			bg = { attribute = "bg", highlight = "Normal" },
			bold = true,
			italic = true,
		},
		pick = {
			fg = { attribute = "fg", highlight = "TabLine" },
			bg = { attribute = "bg", highlight = "TabLine" },
			bold = true,
			italic = true,
		},
		pick_selected = {
			fg = { attribute = "fg", highlight = "Normal" },
			bg = { attribute = "bg", highlight = "Normal" },
			bold = true,
			italic = true,
		},
		pick_visible = {
			fg = { attribute = "fg", highlight = "TabLine" },
			bg = { attribute = "bg", highlight = "TabLine" },
			bold = true,
			italic = true,
		},
		trunc_marker = {
			fg = colors.violet,
			bg = { attribute = "bg", highlight = "Normal" },
			bold = true,
		},
	},
}

return options
