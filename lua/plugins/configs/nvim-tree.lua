local M = {}

M.on_attach = function(bufnr)
	local api = require("nvim-tree.api")
	local map = vim.keymap.set
	local del = vim.keymap.del

	local function opts(desc)
		return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
	end
	map("n", "O", "", { buffer = bufnr })
	del("n", "O", { buffer = bufnr })
	map("n", "<2-RightMouse>", "", { buffer = bufnr })
	del("n", "<2-RightMouse>", { buffer = bufnr })

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

M.options = {
	auto_reload_on_write = true,
	disable_netrw = true,
	hijack_netrw = true,
	hijack_cursor = false, -- Keeps the cursor on the first letter of the filename when moving in the tree.
	hijack_unnamed_buffer_when_opening = true,
	sort_by = "name",
	root_dirs = {},
	prefer_startup_root = false,
	sync_root_with_cwd = true,
	reload_on_bufenter = true,
	respect_buf_cwd = true,
	on_attach = M.on_attach,
	select_prompts = false,
	view = {
		centralize_selection = false,
		cursorline = true,
		debounce_delay = 15,
		width = 28,
		side = "left",
		adaptive_size = false,
		preserve_window_proportions = true,
		number = false,
		relativenumber = false,
		signcolumn = "yes",
	},
	renderer = {
		add_trailing = false,
		group_empty = false,
		highlight_git = false,
		full_name = false,
		highlight_opened_files = "none",
		highlight_modified = "none",
		root_folder_label = ":~:s?$?/..?",
		indent_width = 2,
		indent_markers = {
			enable = false,
			inline_arrows = true,
			icons = {
				corner = "└",
				edge = "│",
				item = "│",
				bottom = "─",
				none = " ",
			},
		},
		icons = {
			webdev_colors = true,
			git_placement = "before",
			modified_placement = "after",
			padding = " ",
			symlink_arrow = " ➛ ",
			show = {
				file = true,
				folder = true,
				folder_arrow = true,
				git = true,
				modified = true,
			},
		},
		special_files = {
			"README.md",
			"LICENSE",
			"Cargo.toml",
			"Makefile",
			"package.json",
			"package-lock.json",
		},
		symlink_destination = true,
	},
	hijack_directories = {
		enable = true,
		auto_open = true,
	},
	update_focused_file = {
		enable = true,
		update_root = true,
		ignore_list = {},
	},
	diagnostics = {
		enable = false,
		show_on_dirs = false,
		show_on_open_dirs = true,
		debounce_delay = 50,
		severity = {
			min = vim.diagnostic.severity.HINT,
			max = vim.diagnostic.severity.ERROR,
		},
		icons = {
			hint = "󰌵 ",
			info = " ",
			warning = " ",
			error = " ",
		},
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
		use_system_clipboard = true,
		change_dir = {
			enable = true,
			global = false,
			restrict_above_cwd = false,
		},
		expand_all = {
			max_folder_discovery = 300,
			exclude = {},
		},
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
			quit_on_open = false,
			resize_window = true,
			window_picker = {
				enable = false,
				picker = "default",
				chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
				exclude = {
					filetype = { "notify", "packer", "qf", "diff", "fugitive", "fugitiveblame", "exe" },
					buftype = { "nofile", "terminal", "help" },
				},
			},
		},
		remove_file = {
			close_window = true,
		},
	},
	trash = {
		--cmd = "gio trash",
		cmd = "trash-put",
	},
	live_filter = {
		prefix = "[FILTER]: ",
		always_show_folders = true,
	},
	tab = {
		sync = {
			open = false,
			close = false,
			ignore = {},
		},
	},
	notify = {
		threshold = vim.log.levels.INFO,
	},
	ui = {
		confirm = {
			remove = true,
			trash = true,
		},
	},
	log = {
		enable = true,
		truncate = false,
		types = {
			all = false,
			config = false,
			copy_paste = false,
			dev = false,
			diagnostics = false,
			git = false,
			profile = false,
			watcher = false,
		},
	},
}

return M.options
