local options = {
	-- custome feature of copilot
	-- run :Copilot auth if not authenticated when starting nvim
	auto_check_auth = false,

	-- main official features support by copilot.lua
	panel = {
		enabled = true,
		auto_refresh = true,
		keymap = {
			jump_prev = "<M-[>",
			jump_next = "<M-]>",
			accept = "<CR>",
			refresh = "R",
			open = "<M-CR>",
		},
		layout = {
			position = "right", -- | top | left | right
			ratio = 0.5,
		},
	},
	suggestion = {
		enabled = true,
		auto_trigger = true,
		debounce = 75,
		keymap = {
			accept = "<M-Tab>",
			accept_word = false,
			accept_line = false,
			next = "<M-]>",
			prev = "<M-[>",
			dismiss = "<C-Tab><M-Tab>",
		},
	},
	filetypes = {
		yaml = true,
		markdown = true,
		help = false,
		gitcommit = false,
		gitrebase = false,
		hgcommit = false,
		svn = false,
		cvs = false,
		sh = true,
		-- sh = function()
		-- 	if string.match(vim.fs.basename(vim.api.nvim_buf_get_name(0)), "^%.env.*") then
		-- 		-- disable for .env files
		-- 		return false
		-- 	end
		-- 	return true
		-- end,
	},
	copilot_node_command = "node", -- Node.js version must be > 16.x
	server_opts_overrides = {},
}

return options
