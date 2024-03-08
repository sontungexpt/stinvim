local api = vim.api
local autocmd = api.nvim_create_autocmd
local augroup = api.nvim_create_augroup
local load_and_exec = require("utils").load_and_exec

local map = require("utils.mapper").map

local M = {}
M.map_on_startup = function()
	------------------------------ url-open ------------------------------
	map({ "n", "v" }, "gx", "<cmd>URLOpenUnderCursor<cr>", { desc = "Open URL under cursor" })

	------------------------------ nvimtree ------------------------------
	map({ "n", "i", "v", "c" }, "<C-b>", function()
		local filetype = api.nvim_buf_get_option(0, "filetype")
		-- local buftype = api.nvim_buf_get_option(0, "buftype")
		if vim.tbl_contains({ "TelescopePrompt", "lazy", "mason" }, filetype) then return end
		api.nvim_command("NvimTreeToggle")
	end, { desc = "Toggle NvimTree" })

	------------------------------ Telescope ------------------------------
	map({ "n", "i", "v" }, "<C-p>", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
	map("n", "<leader>fm", "<cmd>Telescope media_files<cr>", { desc = "Find media files" })
	map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Find word" })
	map("n", "<C-f>", "<cmd>Telescope live_grep<cr>", { desc = "Find word" })
	map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Find buffers" })
	map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Find help tags" })
	map("n", "<leader>fp", "<cmd>Telescope projects<cr>", { desc = "Find recent projects" })

	------------------------------ Git conflict ------------------------------
	map("n", "<Leader>fc", "<cmd>GitConflictListQf<cr>", { desc = "Git conflict quickfix" })

	------------------------------ Todo-comments ------------------------------
	map("n", "<Leader>ft", "<cmd>TodoQuickFix<cr>", { desc = "Todo quickfix" })

	map("n", "[t", function()
		load_and_exec("todo-comments", function(todo_comments) todo_comments.jump_prev() end)
	end, { desc = "Previous todo comment" })

	map("n", "]t", function()
		load_and_exec("todo-comments", function(todo_comments) todo_comments.jump_next() end)
	end, { desc = "Next todo comment" })

	map("n", "[T", function()
		load_and_exec(
			"todo-comments",
			function(todo_comments) todo_comments.jump_prev { keywords = { "ERROR", "WARNING" } } end
		)
	end, { desc = "Previous error/ warning comment" })

	map("n", "]T", function()
		load_and_exec(
			"todo-comments",
			function(todo_comments) todo_comments.jump_next { keywords = { "ERROR", "WARNING" } } end
		)
	end, { desc = "Next error/ warning comment" })

	------------------------------ ccc ------------------------------
	map({ "n", "i", "v" }, "<A-c>", "<cmd>CccPick<cr>", { desc = "Pick color" })

	------------------------------ ufo ------------------------------
	map("n", "zR", "<cmd>lua require('ufo').openAllFolds()<CR>")
	map("n", "zr", "<cmd>lua require('ufo').openFoldsExceptKinds()<CR>")
	map("n", "zM", "<cmd>lua require('ufo').closeAllFolds()<CR>")
	map("n", "zm", "<cmd>lua require('ufo').closeFoldsWith()<CR>")

	------------------------------ Bufferline ------------------------------
	-- map("n", "<Space>", "<Cmd>exe 'BufferLineGoToBuffer ' . v:count1<CR>")

	------------------------------ Markdown preview ------------------------------
	map("n", "<Leader>pm", "<Cmd>MarkdownPreviewToggle<CR>", 6, { desc = "Toggle markdown preview" })

	------------------------------ wilder ------------------------------
	-- map("c", "<C-j>", "has('wilder') && wilder#in_context() ? wilder#next() : '<C-j>'", 5)
	-- map("c", "<C-k>", "has('wilder') && wilder#in_context() ? wilder#previous() : '<C-k>'", 5)

	------------------------------ Lspsaga ------------------------------
	autocmd("LspAttach", {
		desc = "Lspsaga actions",
		group = augroup("Lspsaga-mappings", { clear = true }),
		callback = function()
			map("n", "gf", "<cmd>Lspsaga lsp_finder<CR>")

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
				load_and_exec(
					"lspsaga.diagnostic",
					function(diagnostic) diagnostic:goto_prev { severity = vim.diagnostic.severity.ERROR } end
				)
			end)
			map("n", "]e", function()
				load_and_exec(
					"lspsaga.diagnostic",
					function(diagnostic) diagnostic:goto_next { severity = vim.diagnostic.severity.ERROR } end
				)
			end)

			map("n", "<leader>so", "<cmd>Lspsaga outline<CR>")

			-- -- Call hierarchy
			-- map("n", "<Leader>ci", "<cmd>Lspsaga incoming_calls<CR>")
			-- map("n", "<Leader>co", "<cmd>Lspsaga outgoing_calls<CR>")
		end,
	})

	--------------------------------------- dap ---------------------------------------
	local continue_debugging = require("plugins.configs.dap.utils").continue_debugging

	map("n", "<leader>du", function()
		load_and_exec("dapui", function(dapui) dapui.toggle() end)
	end, { desc = "Toggle DAP UI" })
	map("n", "<leader>db", function()
		load_and_exec("dap", function(dap) dap.toggle_breakpoint() end)
	end, { desc = "Toggle breakpoint" })
	map("n", "<leader>di", function()
		load_and_exec("dap", function(dap) dap.step_into() end)
	end, { desc = "Step into" })
	map("n", "<leader>do", function()
		load_and_exec("dap", function(dap) dap.step_over() end)
	end, { desc = "Step over" })
	map("n", "<leader>dc", function() continue_debugging() end, { desc = "Continue or start debugging" })
	map("n", "<leader>dd", function()
		load_and_exec("dap", function(dap)
			dap.disconnect()
			dap.close()
		end)
	end, { desc = "Disconnect from debugger" })
	map("n", "<F11>", function()
		load_and_exec("dap", function(dap) dap.step_into() end)
	end, { desc = "Step into" })
	map("n", "<F12>", function()
		load_and_exec("dap", function(dap) dap.step_over() end)
	end, { desc = "Step over" })
	map("n", "<F5>", function() continue_debugging() end, { desc = "Continue or start debugging" })
	map("n", "<F4>", function()
		load_and_exec("dap", function(dap)
			dap.disconnect()
			dap.close()
		end)
	end, { desc = "Disconnect from debugger" })
	map("n", "<Leader>dr", function()
		load_and_exec("dap", function(dap) dap.repl.open() end)
	end, { desc = "Open REPL" })
	map("n", "<Leader>dl", function()
		load_and_exec("dap", function(dap) dap.run_last() end)
	end, { desc = "Run last" })

	map({ "n", "v" }, "<Leader>dh", function()
		load_and_exec("dap.ui.widgets", function(widgets) widgets.hover() end)
	end, { desc = "Hover widgets" })
	map({ "n", "v" }, "<Leader>dp", function()
		load_and_exec("dap.ui.widgets", function(widgets) widgets.preview() end)
	end, { desc = "Preview widgets" })
	map("n", "<Leader>df", function()
		load_and_exec("dap.ui.widgets", function(widgets) widgets.centered_float(widgets.frames) end)
	end, { desc = "Frames" })
	map("n", "<Leader>ds", function()
		load_and_exec("dap.ui.widgets", function(widgets) widgets.centered_float(widgets.scopes) end)
	end, { desc = "Scopes" })
end

M.toggleterm = function(bufnr)
	map("n", "q", "<cmd>close<CR>", { buffer = bufnr })
	-- kill terminal buffer
	map("t", "<C-q>", "<C-\\><C-n>:q!<cr>")
	map("t", "<A-q>", "<C-\\><C-n>:q!<cr>")
	map("t", "<esc>", [[<C-\><C-n>]], { buffer = bufnr })

	map("t", "jj", [[<C-\><C-n>]], { buffer = bufnr })
	map("t", "<C-h>", [[<Cmd>wincmd h<CR>]], { buffer = bufnr })
	map("t", "<C-j>", [[<Cmd>wincmd j<CR>]], { buffer = bufnr })
	map("t", "<C-k>", [[<Cmd>wincmd k<CR>]], { buffer = bufnr })
	map("t", "<C-l>", [[<Cmd>wincmd l<CR>]], { buffer = bufnr })
	map("t", "<C-w>", [[<C-\><C-n><C-w>]], { buffer = bufnr })
	map({ "n", "t" }, "<C-t>", [[<Cmd>exe v:count1 . "ToggleTerm"<CR>]], { buffer = bufnr })
end

M.gitsigns = function(bufnr)
	local gs = package.loaded.gitsigns
	local function map1(mode, key, map_to, opts)
		opts.buffer = bufnr
		map(mode, key, map_to, opts)
	end

	-- Navigation
	map1("n", "]g", function()
		if vim.wo.diff then return "]g" end
		vim.schedule(function() gs.next_hunk() end)
		return "<Ignore>"
	end, { expr = true, desc = "Next hunk" })
	map1("n", "[g", function()
		if vim.wo.diff then return "[g" end
		vim.schedule(function() gs.prev_hunk() end)
		return "<Ignore>"
	end, { expr = true, desc = "Prev hunk" })
	map1("n", "<leader>gs", gs.stage_hunk, { desc = "Stage hunk" })
	map1(
		"v",
		"<leader>gs",
		function() gs.stage_hunk { vim.fn.line("."), vim.fn.line("v") } end,
		{ desc = "Stage hunk" }
	)
	map1("n", "<leader>gr", gs.reset_hunk, { desc = "Reset hunk" })
	map1(
		"v",
		"<leader>gr",
		function() gs.reset_hunk { vim.fn.line("."), vim.fn.line("v") } end,
		{ desc = "Reset hunk" }
	)
	map1("n", "<leader>gu", gs.undo_stage_hunk, { desc = "Undo stage hunk" })
	map1("n", "<leader>gR", gs.reset_buffer, { desc = "Reset buffer" })
	map1("n", "<leader>gp", gs.preview_hunk, { desc = "Preview hunk" })
	map1("n", "<leader>gb", gs.toggle_current_line_blame, { desc = "Blame line" })
	map1("n", "<leader>gd", gs.diffthis, { desc = "Diff this" })
	map1("n", "<leader>gD", function() gs.diffthis("~") end, { desc = "Diff this" })
end

return M
