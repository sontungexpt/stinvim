local options = {
	rename = {
		-- https://nvimdev.github.io/lspsaga/rename/
		--
		-- Default is true. Whether the name is selected when the float opens
		-- In some situation, just like want to change one or less characters, in_select is not so useful. You can tell the Lspsaga to start in normal mode using an extra argument like :Lspsaga lsp_rename mode=n
		-- in_select = true
		--
		-- Auto save file when the rename is done
		-- auto_save = false
		--
		-- Width for the project_replace float window
		-- project_max_width = 0.5
		--
		-- Height for the project_replace float window
		-- project_max_height = 0.5
		keys = {
			quit = { "<ESC>", "<C-q>", "<M-q>" },
		},
	},
	scroll_preview = {
		scroll_down = "<C-y>",
		scroll_up = "<C-e>",
	},
	finder = {
		-- https://nvimdev.github.io/lspsaga/finder/
		max_height = 0.5,
		left_width = 0.4,
		right_width = 0.4,
		keys = {
			toggle_or_open = "o",
			vsplit = "<M-v>",
			split = "<M-s>",
			-- tabe = "t",
			-- tabnew = "r",
			quit = { "q", "<ESC>" },
		},
	},
	definition = {
		-- https://nvimdev.github.io/lspsaga/definition/
		width = 0.85, -- defines float window width
		height = 0.6, -- defines float window height
		keys = {
			edit = "o",
			vsplit = "<M-v>",
			split = "<M-s>",
			quit = { "q", "<ESC>" },
		},
	},
	code_action = {
		-- https://nvimdev.github.io/lspsaga/codeaction/
		-- whether number shortcut for code actions are enabled
		-- num_shortcut = true,
		--
		show_server_name = true,
		extend_gitsigns = true,
		keys = {
			quit = { "q", "<ESC>" },
			exec = { "<CR>", "o" },
		},
	},
	lightbulb = {
		enable = false,
		-- show sign in status column
		-- sign = true,
		--
		-- show virtual text at the end of line
		-- virtual_text = true,
		--
		-- timer debounce
		-- debounce = 10,
		--
		-- sign_priority = 40,
	},
	hover = {
		-- https://nvimdev.github.io/lspsaga/hover/
		max_width = 0.9,
		max_height = 0.8,
	},
	diagnostic = {
		-- https://nvimdev.github.io/lspsaga/diagnostic/
		-- show_code_action = true,-- default
		-- jump_num_shortcut = true, -- default
		max_width = 0.7,
		max_height = 0.6,
		-- text_hl_follow = true, -- default
		-- border_follow = true, -- default
		-- extend_relatedInformation = false, -- default
		-- show_layout = 'float'  -- default
		-- max_show_width = 0.9,
		-- max_show_height = 0.6,
		-- diagnostic_only_current = false -- default

		-- keys = {
		-- 	exec_action = "o",
		-- 	quit = "q",
		-- 	toggle_or_jump = "<CR>",
		-- 	quit_in_show = { "q", "<ESC>" },
		-- },
	},
	outline = {
		-- win_position = 'right'
		-- win_width = 30
		--
		-- auto preview when cursor moved in outline window
		-- auto_preview = true
		--
		-- detail = true
		--
		-- auto close itself when outline window is last window
		-- auto_close = true
		--
		-- close_after_jump = false -- close after jump
		--
		-- layout = 'normal' -- float or normal
		--
		-- max_height = 0.5
		-- left_width = 0.3
		--
		-- keys = {
		--   toggle_or_jump = 'o' -- toggle or jump
		--   quit = 'q' -- quit outline window
		--   jump = 'e' -- jump to pos even on a expand/collapse node
		-- },
	},
	callhierarchy = {
		-- layout = 'float', -- normal or float
		keys = {
			edit = "o", --edit (open) file
			vsplit = "<M-v>", -- vsplit
			split = "<M-s>", -- split"
			quit = { "q", "<ESC>" }, -- quit layout
			-- tabe = 't', open in new tab
			-- shuttle = '[w', shuttle bettween the layout left and right
			-- toggle_or_req = 'u', toggle or do request
		},
	},
	symbol_in_winbar = {
		enable = false,
		-- enable = true
		--
		-- Separator symbol
		-- separator = "  ",
		--
		-- When true some symbols like if and for will be ignored (need treesitter)
		-- hide_keyword = true,
		--
		-- Show file name before symbols
		-- show_file = true
		--
		-- Show how many folder layers before the file name
		-- folder_level = 2,
		--
		-- true mean the symbol name and icon have same color. Otherwise, symbol name is light-white
		-- color_mode = true,
		--
		-- Dynamic render delay
		-- delay = 300,
	},
	beacon = {
		enable = true,
		frequency = 7,
	},
	ui = {
		-- Border type, see :help nvim_open_win
		border = "single",
		--
		-- Whether to use nvim-web-devicons
		-- devicon = true,
		--
		-- Show title in some float window
		-- title = false,
		--
		-- Expand icon
		-- expand = "",
		expand = "",
		-- Collapse icon
		collapse = "",
		-- Code action icon
		-- code_action = "💡",
		--
		-- Action fix icon
		-- actionfix = ' ',
		--
		-- Symbols used in virtual text connect
		-- lines = { '┗', '┣', '┃', '━', '┏' },
		--
		-- LSP kind custom table
		-- kind = {},
		--
		-- Implement icon
		-- imp_sign = '󰳛 ',
	},
}

return options
