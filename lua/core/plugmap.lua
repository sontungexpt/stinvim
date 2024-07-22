local api = vim.api
local autocmd, augroup = api.nvim_create_autocmd, api.nvim_create_augroup
local M = {}

vim.schedule(function()
	local map = require("utils.mapper").map
	local load_mod = require("utils").load_mod

	------------------------------ url-open ------------------------------
	map({ "n", "v" }, "gx", "<cmd>URLOpenUnderCursor<cr>", "Open URL under cursor")

	------------------------------ nvimtree ------------------------------
	map({ "n", "i", "v", "c" }, "<C-b>", function()
		local filetype = api.nvim_get_option_value("filetype", { buf = 0 })
		-- local buftype = api.nvim_buf_get_option(0, "buftype")
		if vim.tbl_contains({ "TelescopePrompt", "lazy", "mason" }, filetype) then
			vim.cmd.normal { "<C-b>", bang = true }
		else
			api.nvim_command("NvimTreeToggle")
		end
	end)

	------------------------------ Telescope ------------------------------
	map({ "n", "i", "v" }, "<C-p>", "<cmd>Telescope find_files<cr>")
	map("n", "<leader>fb", "<cmd>Telescope buffers<cr>")
	map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>")

	map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", "Telescope find string")
	map("n", "<C-f>", "<cmd>Telescope live_grep<cr>", "Telescope find string")
	map("n", "<leader>fw", "<cmd>Telescope grep_string<cr>", "Find word under cursor")

	------------------------------ Todo-comments ------------------------------
	map("n", "<Leader>ft", "<cmd>TodoTelescope<cr>", "Telescope find todo comments")

	map("n", "<leader>fd", "<cmd>Telescope diagnostics<cr>")
	map("n", "<leader>fc", "<cmd>Telescope command_history<cr>", "Find command history")

	------------------------------ Todo-comments ------------------------------
	map("n", "<Leader>ft", "<cmd>TodoTelescope<cr>", "Find todo comments")

	------------------------------ Git conflict ------------------------------
	map("n", "<Leader>qfc", "<cmd>GitConflictListQf<cr>", "Git conflict quickfix")

	map("n", "[t", function()
		load_mod("todo-comments", function(todo_comments) todo_comments.jump_prev() end)
	end, "Todo comment prev")

	map("n", "]t", function()
		load_mod("todo-comments", function(todo_comments) todo_comments.jump_next() end)
	end, "Todo comment next")

	map("n", "[T", function()
		load_mod("todo-comments", function(todo_comments) todo_comments.jump_prev { keywords = { "ERROR", "WARNING" } } end)
	end, "Todo comment prev error or warning")

	map("n", "]T", function()
		load_mod("todo-comments", function(todo_comments) todo_comments.jump_next { keywords = { "ERROR", "WARNING" } } end)
	end, "Todo comment next error or warning")

	------------------------------ ccc ------------------------------
	map({ "n", "i", "v" }, "<A-c>", "<cmd>CccPick<cr>", "Color picker")

	------------------------------ ufo ------------------------------
	map("n", "zR", "<cmd>lua require('ufo').openAllFolds()<CR>", "Open all folds")
	map("n", "zr", "<cmd>lua require('ufo').openFoldsExceptKinds()<CR>", "Open folds except kind")
	map("n", "zM", "<cmd>lua require('ufo').closeAllFolds()<CR>", "Close all folds")
	map("n", "zm", "<cmd>lua require('ufo').closeFoldsWith()<CR>", "Close folds with kind")

	------------------------------ Bufferline ------------------------------
	-- map("n", "<Space>", "<Cmd>exe 'BufferLineGoToBuffer ' . v:count1<CR>")

	------------------------------ Markdown preview ------------------------------
	map("n", "<Leader>pm", "<cmd>MarkdownPreviewToggle<CR>", "Toggle markdown preview")

	------------------------------ wilder ------------------------------
	-- map("c", "<C-j>", "has('wilder') && wilder#in_context() ? wilder#next() : '<C-j>'", 6)
	-- map("c", "<C-k>", "has('wilder') && wilder#in_context() ? wilder#previous() : '<C-k>'", 6)
	--

	--------------------------------------- dap ---------------------------------------
	map("n", "<leader>du", function()
		load_mod("dapui", function(dapui) dapui.toggle() end)
	end, "Toggle DAP UI")
	map("n", "<leader>db", function()
		load_mod("dap", function(dap) dap.toggle_breakpoint() end)
	end, "Toggle breakpoint")
	map("n", "<leader>di", function()
		load_mod("dap", function(dap) dap.step_into() end)
	end, "Step into")
	map("n", "<leader>do", function()
		load_mod("dap", function(dap) dap.step_over() end)
	end, "Step over")
	map("n", "<leader>dc", function()
		load_mod("dap", function(dap) dap.continue() end)
	end, "Continue or start debugging")
	map("n", "<leader>dd", function()
		load_mod("dap", function(dap)
			dap.disconnect()
			dap.close()
		end)
	end, "Disconnect from debugger")
	map("n", "<F11>", function()
		load_mod("dap", function(dap) dap.step_into() end)
	end, "Step into")
	map("n", "<F12>", function()
		load_mod("dap", function(dap) dap.step_over() end)
	end, "Step over")
	map("n", "<F5>", function()
		load_mod("dap", function(dap) dap.continue() end)
	end, "Continue or start debugging")
	map("n", "<F4>", function()
		load_mod("dap", function(dap)
			dap.disconnect()
			dap.close()
		end)
	end, "Disconnect from debugger")
	map("n", "<Leader>dr", function()
		load_mod("dap", function(dap) dap.repl.open() end)
	end, "Open REPL")
	map("n", "<Leader>dl", function()
		load_mod("dap", function(dap) dap.run_last() end)
	end, "Run last")

	map({ "n", "v" }, "<Leader>dh", function()
		load_mod("dap.ui.widgets", function(widgets) widgets.hover() end)
	end, "Hover widgets")
	map({ "n", "v" }, "<Leader>dp", function()
		load_mod("dap.ui.widgets", function(widgets) widgets.preview() end)
	end, "Preview widgets")
	map("n", "<Leader>df", function()
		load_mod("dap.ui.widgets", function(widgets) widgets.centered_float(widgets.frames) end)
	end, "Frames")
	map("n", "<Leader>ds", function()
		load_mod("dap.ui.widgets", function(widgets) widgets.centered_float(widgets.scopes) end)
	end, "Scopes")
end)

autocmd("LspAttach", {
	group = augroup("Lspsaga-mappings", { clear = true }),
	desc = "Lspsaga actions",
	once = true,
	callback = function()
		local map = require("utils.mapper").map
		local load_mod = require("utils").load_mod

		map("n", "gf", "<cmd>Lspsaga finder<CR>")

		map({ "n", "v" }, "<leader>sa", "<cmd>Lspsaga code_action<CR>")

		map("n", "gr", "<cmd>Lspsaga rename<CR>")

		-- map("n", "<leader>gr", "<cmd>Lspsaga rename ++project<CR>")

		map("n", "gp", "<cmd>Lspsaga peek_definition<CR>")

		map("n", "gd", "<cmd>Lspsaga goto_definition<CR>")

		map("n", "gt", "<cmd>Lspsaga peek_type_definition<CR>")

		map("n", "K", function()
			local status_ok, ufo = pcall(require, "ufo")
			local winid = status_ok and ufo.peekFoldedLinesUnderCursor() or nil
			if not winid then api.nvim_command("Lspsaga hover_doc") end
		end)

		map("n", "gl", "<cmd>Lspsaga show_line_diagnostics ++unfocus<CR>")

		map("n", "<leader>sb", "<cmd>Lspsaga show_buf_diagnostics<CR>")

		map("n", "<leader>sw", "<cmd>Lspsaga show_workspace_diagnostics<CR>")

		map("n", "<leader>sc", "<cmd>Lspsaga show_cursor_diagnostics<CR>")

		map("n", "[d", "<cmd>Lspsaga diagnostic_jump_prev<CR>")
		map("n", "]d", "<cmd>Lspsaga diagnostic_jump_next<CR>")

		map("n", "[e", function()
			load_mod("lspsaga.diagnostic", function(diagnostic) diagnostic:goto_prev { severity = 1 } end)
		end, "Lspsaga diagnostic_jump_prev error")
		map("n", "]e", function()
			load_mod("lspsaga.diagnostic", function(diagnostic) diagnostic:goto_next { severity = 1 } end)
		end, "Lspsaga diagnostic_jump_next error")

		map("n", "<leader>so", "<cmd>Lspsaga outline<CR>")

		-- -- Call hierarchy
		-- map("n", "<Leader>ci", "<cmd>Lspsaga incoming_calls<CR>")
		-- map("n", "<Leader>co", "<cmd>Lspsaga outgoing_calls<CR>")
	end,
})

M.gitsigns = function(bufnr)
	local map = require("utils.mapper").map
	local gs = require("gitsigns")

	local map1 = function(mode, key, map_to, desc) map(mode, key, map_to, { buffer = bufnr, desc = desc }) end

	-- Navigation
	map1("n", "]g", function()
		if vim.wo.diff then
			vim.cmd.normal { "]g", bang = true }
		else
			gs.nav_hunk("next")
		end
	end, "Gitsigns next hunk")
	map("n", "[g", function()
		if vim.wo.diff then
			vim.cmd.normal { "[g", bang = true }
		else
			gs.nav_hunk("prev")
		end
	end, "Gitsigns previous hunk")

	map1("n", "<leader>gs", gs.stage_hunk, "Gitsigns stage hunk")
	map1("v", "<leader>gs", function() gs.stage_hunk { vim.fn.line("."), vim.fn.line("v") } end, "Gitsigns stage hunk")
	map1("n", "<leader>gr", gs.reset_hunk, "Reset hunk")
	map1("v", "<leader>gr", function() gs.reset_hunk { vim.fn.line("."), vim.fn.line("v") } end, "Gitsigns reset hunk")
	map1("n", "<leader>gu", gs.undo_stage_hunk, "Gitsigns undo stage hunk")
	map1("n", "<leader>gR", gs.reset_buffer, "Gitsigns reset buffer")
	map1("n", "<leader>gp", gs.preview_hunk, "Gitsigns preview hunk")
	map1("n", "<leader>gb", gs.toggle_current_line_blame, "Gitsigns blame line")
	map1("n", "<leader>gd", gs.diffthis, "Gitsigns diff this")
	map1("n", "<leader>gD", function() gs.diffthis("~") end, "Gitsigns diff this")
end

return M
