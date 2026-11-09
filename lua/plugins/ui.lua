-- ------------------------------------------------- UI -------------------------------------------------
-- User interface plugins.
-- Mission: Interface elements and interactions (keymap hints, file picker, explorer, notifier, terminal).
return {
	-- Keymap hint layer
	{
		"folke/which-key.nvim",
		keys = { "<leader>", "[", "]", '"', "'", "c", "v", "g", "d", "z" },
		main = "which-key",
		opts = {
			win = {
				border = "single",
			},
		},
	},

	-- UI suite: picker, explorer, notifier, dashboard, etc.
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = {
			picker = {
				enabled = true,
			},
			explorer = {
				enabled = true,
				replace_netrw = true,
			},
			notifier = {
				enabled = true,
				timeout = 3000,
			},
			image = {
				enabled = false,
			},
			dashboard = {
				enabled = false,
			},
			indent = {
				enabled = false,
				only_current = false,
				only_scope = false,
				only_toplevel = false,
				char = "│",
			},
			lazygit = {
				enabled = false,
			},
			rename = {
				enabled = false,
			},
			scope = {
				enabled = true,
			},
			words = {
				enabled = true,
			},
			styles = {
				notification = {
					wo = { wrap = true },
				},
			},
		},
	},
}
