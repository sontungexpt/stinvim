-- local no_actions = function(prompt_bufnr) print("No actions available!") end

local sorters, previewers, actions =
	require("telescope.sorters"), require("telescope.previewers"), require("telescope.actions")

local options = {
	extensions_list = {
		"media_files",
		"fzy_native",
		-- "projects",
		-- "zoxide",
		-- "neoclip",
	},
	defaults = {
		find_command = {
			"rg",
			"-L",
			"--color=never",
			"--no-heading",
			"--with-filename",
			"--line-number",
			"--column",
			"--smart-case",
		},
		vimgrep_arguments = {
			"rg",
			"-L",
			"--color=never",
			"--no-heading",
			"--with-filename",
			"--line-number",
			"--column",
			"--smart-case",
		},
		layout_config = {
			horizontal = {
				prompt_position = "top",
				preview_width = 0.55,
				results_width = 0.8,
			},
			vertical = {
				mirror = false,
			},
			width = 0.87,
			height = 0.9,
			preview_cutoff = 120,
		},
		prompt_prefix = "  ",
		selection_caret = "  ",
		entry_prefix = "  ",
		initial_mode = "insert",
		selection_strategy = "reset",
		sorting_strategy = "ascending",
		layout_strategy = "horizontal",
		mappings = {
			i = {
				["<C-p>"] = actions.close, -- support to toggle telescope
				["<esc>"] = actions.close,
				["<C-q>"] = actions.close,
				["<A-q>"] = actions.close,
				["<C-j>"] = actions.move_selection_next,
				["<C-k>"] = actions.move_selection_previous,
				["<Tab>"] = actions.move_selection_next,
				["<S-Tab>"] = actions.move_selection_previous,
				["<C-e>"] = actions.results_scrolling_up,
				["<C-y>"] = actions.results_scrolling_down,
				["<C-u>"] = actions.preview_scrolling_up,
				["<C-d>"] = actions.preview_scrolling_down,
			},
			n = {
				["<C-p>"] = actions.close, -- support to toggle telescope
				["q"] = actions.close,
				["<esc>"] = actions.close,
				["<C-q>"] = actions.close,
				["<A-q>"] = actions.close,
				["<C-e>"] = actions.results_scrolling_up,
				["<C-y>"] = actions.results_scrolling_down,
				["<C-u>"] = actions.preview_scrolling_up,
				["<C-d>"] = actions.preview_scrolling_down,
				["<Tab>"] = actions.move_selection_next,
				["<S-Tab>"] = actions.move_selection_previous,
			},
		},
		file_ignore_patterns = {
			"^.git/",
			"^./.git/",
			"^node_modules/",
			"^build/",
			"^dist/",
			"^target/",
			"^vendor/",
			"^lazy%-lock%.json$",
			"^package%-lock%.json$",
		},
		path_display = { "smart" },
		winblend = 0,
		border = {},
		borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
		color_devicons = true,
		use_less = true,
		set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
		file_sorter = sorters.get_fuzzy_file,
		generic_sorter = sorters.get_generic_fuzzy_sorter,
		file_previewer = previewers.vim_buffer_cat.new,
		grep_previewer = previewers.vim_buffer_vimgrep.new,
		qflist_previewer = previewers.vim_buffer_qflist.new,
		buffer_previewer_maker = previewers.buffer_previewer_maker,
	},
	pickers = {
		planets = {
			show_pluto = true,
		},
		find_files = {
			hidden = true,
		},
	},
	extensions = {
		fzy_native = {
			override_generic_sorter = true,
			override_file_sorter = true,
		},
		media_files = {
			filetypes = { "png", "webp", "jpg", "jpeg", "webm", "pdf", "mp4" },
			find_cmd = "rg",
		},
	},
}

return options
