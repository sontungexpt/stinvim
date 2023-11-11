-- local function get_node_path()
-- 	local node_dir = vim.fn.expand("$HOME") .. "/.nvm/versions/node"

-- 	if vim.fn.isdirectory(node_dir) == 0 then return "node" end

-- 	-- get the latest version of node
-- 	local node_version = vim.fn.system("ls -v " .. node_dir .. " | tail -n 1")

-- 	if vim.fn.empty(node_version) == 1 then return "node" end
-- 	return node_dir .. "/" .. node_version .. "/bin/node"
-- end
local options = {
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
	},
	-- change this to your node binary path
	copilot_node_command = vim.fn.expand("$HOME") .. "/.nvm/versions/node/v21.0.0/bin/node",
	-- copilot_node_command = "node",
	server_opts_overrides = {},
}

return options
