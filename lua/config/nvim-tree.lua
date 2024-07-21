local on_attach = function(bufnr)
	local api = require("nvim-tree.api")
	api.events.subscribe(api.events.Event.TreeOpen, function() vim.wo.statusline = " " end)

	local map = vim.keymap.set
	local function opts(desc)
		return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
	end

	map("n", "<CR>", api.node.open.edit, opts("Open"))
	map("n", "o", api.node.open.edit, opts("Open"))
	map("n", "cd", api.tree.change_root_to_node, opts("CD"))
	map("n", "v", api.node.open.vertical, opts("Open: Vertical Split"))
	map("n", "s", api.node.open.horizontal, opts("Open: Horizontal Split"))
	map("n", "<Tab>", api.node.open.tab, opts("Open: New Tab"))
	map("n", "P", api.node.navigate.parent, opts("Parent Directory"))
	map("n", "<BS>", api.node.navigate.parent_close, opts("Close Directory"))
	map("n", "<Tab>", api.node.open.preview, opts("Open Preview"))
	map("n", "K", api.node.navigate.sibling.first, opts("First Sibling"))
	map("n", "J", api.node.navigate.sibling.last, opts("Last Sibling"))
	map("n", "C", api.tree.toggle_git_clean_filter, opts("Toggle Git Clean"))
	map("n", "I", api.tree.toggle_gitignore_filter, opts("Toggle Git Ignore"))
	map("n", "R", api.tree.reload, opts("Refresh"))
	map("n", "a", api.fs.create, opts("Create"))
	map("n", "D", api.fs.remove, opts("Delete"))
	map("n", "dd", api.fs.trash, opts("Trash"))
	map("n", "r", api.fs.rename, opts("Rename"))
	map("n", "<C-r>", api.fs.rename_sub, opts("Rename: Omit Filename"))
	map("n", "x", api.fs.cut, opts("Cut"))
	map("n", "yy", api.fs.copy.node, opts("Copy"))
	map("n", "yn", api.fs.copy.filename, opts("Copy Name"))
	map("n", "yt", api.fs.copy.relative_path, opts("Copy Relative Path"))
	map("n", "yp", api.fs.copy.absolute_path, opts("Copy Absolute Path"))
	map("n", "p", api.fs.paste, opts("Paste"))
	map("n", "-", api.tree.change_root_to_parent, opts("Up"))
	map("n", "O", api.node.run.system, opts("Run System"))
	map("n", "f", api.live_filter.start, opts("Filter"))
	map("n", "F", api.live_filter.clear, opts("Clean Filter"))
	map("n", "q", api.tree.close, opts("Close"))
	map("n", "W", api.tree.collapse_all, opts("Collapse"))
	map("n", "<C-f>", api.tree.search_node, opts("Search"))
	map("n", "<C-k>", api.node.show_info_popup, opts("Info"))
	map("n", "?", api.tree.toggle_help, opts("Help"))
	map("n", " ", api.marks.toggle, opts("Toggle Bookmark"))
end

local options = {
	disable_netrw = true,
	hijack_cursor = false, -- Keeps the cursor on the first letter of the filename when moving in the tree.
	hijack_unnamed_buffer_when_opening = true,
	sync_root_with_cwd = true,
	reload_on_bufenter = true,
	respect_buf_cwd = true,
	on_attach = on_attach,
	select_prompts = false,
	view = {
		cursorline = true,
		width = 32,
		side = "left",
		adaptive_size = false,
		number = false,
		relativenumber = false,
		signcolumn = "yes",
	},
	renderer = {
		special_files = {
			"README.md",
		}, -- add highlight if is special file
	},
	update_focused_file = {
		enable = true,
		update_root = true,
		ignore_list = {},
	},
	filters = {
		dotfiles = false,
		git_clean = false,
		no_buffer = false,
		custom = {
			"zsh_history_fix",
			"node_modules",
			".husky",
			"*.ppt",
			"*.exe",
			".rbenv",
			"yay",
		},
		exclude = {},
	},
	filesystem_watchers = {
		enable = true,
		debounce_delay = 50,
		ignore_dirs = { "node_modules", ".git", ".cache", "target", "dist" },
	},
	git = {
		enable = true,
		ignore = false,
		show_on_dirs = true,
		show_on_open_dirs = true,
		timeout = 400,
	},
	modified = {
		enable = false,
		show_on_dirs = true,
		show_on_open_dirs = true,
	},
	actions = {
		file_popup = {
			open_win_config = {
				col = 1,
				row = 1,
				relative = "cursor",
				border = "single", -- shadow, single, double, rounded
				style = "minimal",
			},
		},
		open_file = {
			window_picker = {
				enable = false,
			},
		},
	},
	-- trash = {
	-- 	cmd = "trash-put",
	-- },
	ui = {
		confirm = {
			remove = true,
			trash = true,
		},
	},
}

return options
