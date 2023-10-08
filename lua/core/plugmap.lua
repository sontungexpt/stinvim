local api = vim.api

---
-- default opts = 1
-- opts = 1 for noremap and silent
-- opts = 2 for not noremap and silent
-- opts = 3 for noremap and not silent
-- opts = 4 for not noremap and not silent
-- opts = 5 for expr and noremap and silent
-- opts = 6 for noremap and silent and nowait
-- opts = 7 for noremap and silent and nowait and expr
local map = require("utils.mapper").map

local M = {}

M["telescope.nvim"] = {
	{
		mode = { "n", "i", "v" },
		key = "<C-p>",
		map_to = "<esc>:Telescope find_files<cr>",
		desc = "Find files",
		opts = {},
	},
	{
		mode = "n",
		key = "<leader>fm",
		map_to = "<esc>:Telescope media_files<cr>",
		desc = "Find media files",
	},
	{
		mode = "n",
		key = "<leader>fg",
		map_to = "<esc>:Telescope live_grep<cr>",
		desc = "Find word",
	},
	{
		mode = "n",
		key = "<C-f>",
		map_to = "<esc>:Telescope live_grep<cr>",
		desc = "Find word",
	},
	{
		mode = "n",
		key = "<leader>fb",
		map_to = "<esc>:Telescope buffers<cr>",
		desc = "Find buffers",
	},
	{
		mode = "n",
		key = "<leader>fh",
		map_to = "<esc>:Telescope help_tags<cr>",
		desc = "Find help tags",
	},
	{
		mode = "n",
		key = "<leader>fp",
		map_to = "<esc>:Telescope projects<cr>",
		desc = "Find recent projects",
	},
}

M["nvim-tree.lua"] = {
	{
		mode = { "n", "i", "v", "c" },
		key = "<C-b>",
		map_to = function()
			local filetype = api.nvim_buf_get_option(0, "filetype")
			-- local buftype = api.nvim_buf_get_option(0, "buftype")
			if vim.tbl_contains({ "TelescopePrompt", "lazy", "mason" }, filetype) then
				return
			end
			api.nvim_command("NvimTreeToggle")
		end,
		desc = "Toggle NvimTree",
	},
}

M["todo-comments.nvim"] = {
	{
		mode = "n",
		key = "<Leader>ft",
		map_to = "<cmd>TodoQuickFix<cr>",
		desc = "Todo comments",
	},
	{
		mode = "n",
		key = "[t",
		map_to = ":lua require('todo-comments').jump_prev()<cr>",
		desc = "Previous todo comment",
	},
	{
		mode = "n",
		key = "]t",
		map_to = ":lua require('todo-comments').jump_next()<cr>",
		desc = "Next todo comment",
	},
	{
		mode = "n",
		key = "[T",
		map_to = ":lua require('todo-comments').jump_prev { keywords = { 'ERROR', 'WARNING' } }<cr>",
		desc = "Previous error/ warning comment",
	},
	{
		mode = "n",
		key = "[T",
		map_to = ":lua require('todo-comments').jump_next { keywords = { 'ERROR', 'WARNING' } }<cr>",
		desc = "Previous error/ warning comment",
	},
}

M["ccc.nvim"] = {
	{
		mode = { "n", "i", "v" },
		key = "<A-c>",
		map_to = "<esc>:CccPick<cr>",
		desc = "Pick color",
	},
}

M["git-conflict.nvim"] = {
	{
		mode = "n",
		key = "<Leader>fc",
		map_to = "<cmd>GitConflictListQf<cr>",
		desc = "Git conflict quickfix",
	},
}

M["markdown-preview.nvim"] = {
	{
		mode = "n",
		key = "<Leader>pm",
		map_to = "<Cmd>MarkdownPreviewToggle<CR>",
		desc = "Toggle markdown preview",
	},
}

M["wilder.nvim"] = {
	{
		mode = "c",
		key = "<C-j>",
		map_to = "wilder#in_context() ? wilder#next() : '<C-j>'",
		opts = 7,
	},
	{
		mode = "c",
		key = "<C-j>",
		map_to = "wilder#in_context() ? wilder#previous() : '<C-k>'",
		opts = 7,
	},
}

M["nvim-ufo"] = {
	{
		mode = "n",
		key = "zR",
		map_to = ":lua require('ufo').openAllFolds()",
	},
	{
		mode = "n",
		key = "zr",
		map_to = ":lua require('ufo').openFoldsExceptKinds()",
	},
	{
		mode = "n",
		key = "zM",
		map_to = ":lua require('ufo').closeAllFolds()",
	},
	{
		mode = "n",
		key = "zm",
		map_to = ":lua require('ufo').closeFoldsWith()",
	},
}

M["lspsaga.nvim"] = {
	{
		mode = { "n", "v" },
		key = "<leader>sa",
		map_to = "<cmd>Lspsaga code_action<CR>",
	},
	{
		mode = "n",
		key = "gr",
		map_to = "<cmd>Lspsaga rename<CR>",
	},
	{
		mode = "n",
		key = "gp",
		map_to = "<cmd>Lspsaga peek_definition<CR>",
	},
	{
		mode = "n",
		key = "gd",
		map_to = "<cmd>Lspsaga goto_definition<CR>",
	},
	{
		mode = "n",
		key = "gt",
		map_to = "<cmd>Lspsaga peek_type_definition<CR>",
	},
	{
		mode = "n",
		key = "K",
		map_to = function()
			local status_ok, ufo = pcall(require, "ufo")
			local winid = status_ok and ufo.peekFoldedLinesUnderCursor() or nil
			if not winid then
				api.nvim_command("Lspsaga hover_doc")
			end
		end,
	},
	{
		mode = "n",
		key = "gl",
		map_to = "<cmd>Lspsaga show_line_diagnostics ++unfocus<CR>",
	},
	{
		mode = "n",
		key = "<leader>sb",
		map_to = "<cmd>Lspsaga show_buf_diagnostics<CR>",
	},
	{
		mode = "n",
		key = "<leader>sw",
		map_to = "<cmd>Lspsaga show_workspace_diagnostics<CR>",
	},
	{
		mode = "n",
		key = "<leader>sc",
		map_to = "<cmd>Lspsaga show_cursor_diagnostics<CR>",
	},
	{
		mode = "n",
		key = "[d",
		map_to = "<cmd>Lspsaga diagnostic_jump_prev<CR>",
	},
	{
		mode = "n",
		key = "]d",
		map_to = "<cmd>Lspsaga diagnostic_jump_next<CR>",
	},
	{
		mode = "n",
		key = "[e",
		map_to = "<cmd>lua lspsaga_diagnostic:goto_prev { severity = vim.diagnostic.severity.ERROR }<CR>",
	},
	{
		mode = "n",
		key = "]e",
		map_to = "<cmd>lua lspsaga_diagnostic:goto_next { severity = vim.diagnostic.severity.ERROR }<CR>",
	},
	{
		mode = "n",
		key = "<leader>so",
		map_to = "<cmd>Lspsaga outline<CR>",
	},
}

M["url-open"] = {
	{
		mode = { "n", "v" },
		key = "gx",
		map_to = "<esc>:URLOpenUnderCursor<cr>",
		desc = "Open URL under cursor",
	},
}

--- Load keymap for plugins
--- @tparam string plug_name
--- @tparam boolean release_memmory
--- @usage require("core.plugmap").load("telescope")
M.load = function(plug_name, release_memory)
	release_memory = release_memory or false

	for _, map_opts in ipairs(M[plug_name]) do
		if map_opts.desc then
			map_opts.opts = map_opts.opts or {}
			map_opts.opts.desc = map_opts.desc
		end
		map(map_opts.mode, map_opts.key, map_opts.map_to, map_opts.opts)
	end

	if release_memory then
		M[plug_name] = nil
	end
end

return M
