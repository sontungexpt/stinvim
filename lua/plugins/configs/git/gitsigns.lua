local options = {
	signs = {
		add = { text = "+" },
		change = { text = "│" },
		delete = { text = "_" },
		topdelete = { text = "‾" },
		changedelete = { text = "~" },
		untracked = { text = "┆" },
	},
	signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
	numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
	linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
	word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
	watch_gitdir = {
		interval = 1000,
		follow_files = true,
	},
	attach_to_untracked = true,
	current_line_blame = true, -- Toggle with `:Gitsigns toggle_current_line_blame`
	current_line_blame_opts = {
		virt_text = true,
		virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
		delay = 500,
		ignore_whitespace = false,
	},
	current_line_blame_formatter = "<author>, <author_time:%d-%m-%Y> - <summary>",
	sign_priority = 6,
	update_debounce = 100,
	status_formatter = nil, -- Use default
	max_file_length = 40000, -- Disable if file is longer than this (in lines)
	preview_config = {
		-- Options passed to nvim_open_win
		border = "single",
		style = "minimal",
		relative = "cursor",
		row = 0,
		col = 1,
	},
	yadm = {
		enable = false,
	},
	on_attach = function(bufnr)
		-- local gs = package.loaded.gitsigns
		-- local function map(mode, key, map_to, opts)
		-- 	opts.buffer = bufnr
		-- 	require("core.utils").map(mode, key, map_to, opts)
		-- end

		-- -- Navigation
		-- map("n", "]g", function()
		-- 	if vim.wo.diff then
		-- 		return "]g"
		-- 	end
		-- 	vim.schedule(function()
		-- 		gs.next_hunk()
		-- 	end)
		-- 	return "<Ignore>"
		-- end, { expr = true, desc = "Next hunk" })
		-- map("n", "[g", function()
		-- 	if vim.wo.diff then
		-- 		return "[g"
		-- 	end
		-- 	vim.schedule(function()
		-- 		gs.prev_hunk()
		-- 	end)
		-- 	return "<Ignore>"
		-- end, { expr = true, desc = "Prev hunk" })
		-- map("n", "<leader>gs", gs.stage_hunk, { desc = "Stage hunk" })
		-- map("v", "<leader>gs", function()
		-- 	gs.stage_hunk { vim.fn.line("."), vim.fn.line("v") }
		-- end, { desc = "Stage hunk" })
		-- map("n", "<leader>gr", gs.reset_hunk, { desc = "Reset hunk" })
		-- map("v", "<leader>gr", function()
		-- 	gs.reset_hunk { vim.fn.line("."), vim.fn.line("v") }
		-- end, { desc = "Reset hunk" })
		-- map("n", "<leader>gu", gs.undo_stage_hunk, { desc = "Undo stage hunk" })
		-- map("n", "<leader>gR", gs.reset_buffer, { desc = "Reset buffer" })
		-- map("n", "<leader>gp", gs.preview_hunk, { desc = "Preview hunk" })
		-- map("n", "<leader>gb", gs.toggle_current_line_blame, { desc = "Blame line" })
		-- map("n", "<leader>gd", gs.diffthis, { desc = "Diff this" })
		-- map("n", "<leader>gD", function()
		-- 	gs.diffthis("~")
		-- end, { desc = "Diff this" })
	end,
}

return options
