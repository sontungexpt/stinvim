-- ---------------------------------------------------- Git ----------------------------------------------------
-- Version control integration plugins.
-- Mission: Git signs, blame, hunk navigation, and conflict resolution (gitsigns, git-conflict).
return {
	{
		"lewis6991/gitsigns.nvim",
		event = "User GitLazyLoaded",
		opts = {
			signs = {
				add = { text = "+" },
				change = { text = "│" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
			},
			preview_config = {
				border = "single",
			},
			current_line_blame_opts = {
				virt_text_pos = "right_align",
				delay = 500,
				ignore_whitespace = false,
			},
			current_line_blame = true,
			current_line_blame_formatter = "<author>, <author_time:%d-%m-%Y> - <summary>",
			on_attach = require("core.keymaps").gitsigns,
		},
	},
	{
		"akinsho/git-conflict.nvim",
		event = "User GitLazyLoaded",
		opts = function()
			vim.api.nvim_create_autocmd("User", {
				pattern = { "GitConflictDetected", "GitConflictResolved" },
				callback = function(args)
					if args.match == "GitConflictDetected" then
						require("utils.notify").warn("Conflict detected in " .. args.file)
					else
						require("utils.notify").info("Conflict resolved in " .. args.file)
					end
				end,
			})
			return {
				default_mappings = {
					ours = "o",
					theirs = "t",
					none = "0",
					both = "b",
					next = "]c",
					prev = "[c",
				},
				disable_diagnostics = true,
				highlights = {
					incoming = "DiffText",
					current = "DiffAdd",
				},
			}
		end,
	},
}
