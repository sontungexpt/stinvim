local api = vim.api
local autocmd = api.nvim_create_autocmd
local augroup = api.nvim_create_augroup

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
local load_and_exec = require("utils").load_and_exec

local M = {}
M.map_on_startup = function()
	------------------------------ url-open ------------------------------
	map({ "n", "v" }, "gx", "<esc>:URLOpenUnderCursor<cr>", { desc = "Open URL under cursor" })

	------------------------------ nvimtree ------------------------------
	map({ "n", "i", "v", "c" }, "<C-b>", function()
		local filetype = api.nvim_buf_get_option(0, "filetype")
		-- local buftype = api.nvim_buf_get_option(0, "buftype")
		if vim.tbl_contains({ "TelescopePrompt", "lazy", "mason" }, filetype) then return end
		api.nvim_command("NvimTreeToggle")
	end, { desc = "Toggle NvimTree" })

	------------------------------ Telescope ------------------------------
	map({ "n", "i", "v" }, "<C-p>", "<esc>:Telescope find_files<cr>", { desc = "Find files" })
	map("n", "<leader>fm", "<esc>:Telescope media_files<cr>", { desc = "Find media files" })
	map("n", "<leader>fg", "<esc>:Telescope live_grep<cr>", { desc = "Find word" })
	map("n", "<C-f>", "<esc>:Telescope live_grep<cr>", { desc = "Find word" })
	map("n", "<leader>fb", "<esc>:Telescope buffers<cr>", { desc = "Find buffers" })
	map("n", "<leader>fh", "<esc>:Telescope help_tags<cr>", { desc = "Find help tags" })
	map("n", "<leader>fp", "<esc>:Telescope projects<cr>", { desc = "Find recent projects" })

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
	map({ "n", "i", "v" }, "<A-c>", "<esc>:CccPick<cr>", { desc = "Pick color" })

	------------------------------ ufo ------------------------------
	map("n", "zR", ":lua require('ufo').openAllFolds()<CR>")
	map("n", "zr", ":lua require('ufo').openFoldsExceptKinds()<CR>")
	map("n", "zM", ":lua require('ufo').closeAllFolds()<CR>")
	map("n", "zm", ":lua require('ufo').closeFoldsWith()<CR>")

	------------------------------ Bufferline ------------------------------
	map("n", "<Space>", "<Cmd>exe 'BufferLineGoToBuffer ' . v:count1<CR>")

	------------------------------ Markdown preview ------------------------------
	map("n", "<Leader>pm", "<Cmd>MarkdownPreviewToggle<CR>", { desc = "Toggle markdown preview" })

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
			-- Rename all occurrences of the hovered word for the selected files
			-- keymap("n", "gr", "<cmd>Lspsaga rename ++project<CR>")

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
					function(m) m:goto_prev { severity = vim.diagnostic.severity.ERROR } end
				)
			end)
			map("n", "]e", function()
				load_and_exec(
					"lspsaga.diagnostic",
					function(m) m:goto_next { severity = vim.diagnostic.severity.ERROR } end
				)
			end)

			map("n", "<leader>so", "<cmd>Lspsaga outline<CR>")

			-- -- Call hierarchy
			-- map("n", "<Leader>ci", "<cmd>Lspsaga incoming_calls<CR>")
			-- map("n", "<Leader>co", "<cmd>Lspsaga outgoing_calls<CR>")
		end,
	})

	-- local continue_debugging = require("plugins.configs.dap.utils").continue_debugging

	-- -- dap
	-- map("n", "<leader>du", function() require("dapui").toggle() end, { desc = "Toggle DAP UI" })
	-- map("n", "<leader>db", ":lua require'dap'.toggle_breakpoint()<CR>", { desc = "Toggle breakpoint" })
	-- map("n", "<leader>di", ":lua require'dap'.step_into()<CR>", { desc = "Step into" })
	-- map("n", "<leader>do", ":lua require'dap'.step_over()<CR>", { desc = "Step over" })
	-- map("n", "<leader>dc", function() continue_debugging() end, { desc = "Continue or start debugging" })
	-- map(
	-- 	"n",
	-- 	"<leader>dd",
	-- 	":lua require 'dap'.disconnect()<CR>:lua require'dap'.close()<CR>",
	-- 	{ desc = "Disconnect from debugger" }
	-- )
	-- -- map("n", "<leader>dc", ":lua require'dap'.continue()<CR>")
	-- map("n", "<F11>", ":lua require'dap'.step_into()<CR>", { desc = "Step into" })
	-- map("n", "<F12>", ":lua require'dap'.step_over()<CR>", { desc = "Step over" })
	-- map("n", "<F5>", function() continue_debugging() end, { desc = "Continue or start debugging" })
	-- map(
	-- 	"n",
	-- 	"<F4>",
	-- 	":lua require 'dap'.disconnect()<CR>:lua require'dap'.close()<CR>",
	-- 	{ desc = "Disconnect from debugger" }
	-- )

	-- map("n", "<Leader>dr", ":lua require('dap').repl.open()<CR>", { desc = "Open REPL" })
	-- map("n", "<Leader>dl", ":lua require('dap').run_last()<CR>", { desc = "Run last" })
	-- map({ "n", "v" }, "<Leader>dh", ":lua require('dap.ui.widgets').hover()<CR>", { desc = "Hover" })
	-- map({ "n", "v" }, "<Leader>dp", ":lua require('dap.ui.widgets').preview()<CR>", { desc = "Preview" })
	-- map("n", "<Leader>df", function()
	-- 	local widgets = require("dap.ui.widgets")
	-- 	widgets.centered_float(widgets.frames)
	-- end, { desc = "Frames" })
	-- map("n", "<Leader>ds", function()
	-- 	local widgets = require("dap.ui.widgets")
	-- 	widgets.centered_float(widgets.scopes)
	-- end, { desc = "Scopes" })
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

return M
