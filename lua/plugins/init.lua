local load_on_file_open = require("utils.lazyloader").load_on_file_open
local load_on_repo_open = require("utils.lazyloader").load_on_repo_open
local plug_loadmap = require("core.plugmap").load

local plugins = {
	--------------------------------------------------- Theme ---------------------------------------------------
	{
		"folke/tokyonight.nvim",
		priority = 1000,
		lazy = false,
		opts = require("plugins.configs.tokyonight"),
		config = function(_, opts)
			require("tokyonight").setup(opts)
			vim.api.nvim_command([[colorscheme tokyonight]])
		end,
	},

	--------------------------------------------------- Syntax ---------------------------------------------------
	{
		"nvim-treesitter/nvim-treesitter",
		dependencies = {
			"HiPhish/rainbow-delimiters.nvim",
		},
		init = function() load_on_file_open("nvim-treesitter") end,
		cmd = {
			"TSInstall",
			"TSInstallFromGrammar",
			"TSBufEnable",
			"TSBufDisable",
			"TSModuleInfo",
		},
		build = ":TSUpdate",
		opts = require("plugins.configs.nvim-treesitter"),
		config = function(_, opts) require("nvim-treesitter.configs").setup(opts) end,
	},

	------------------------------------ Editor ------------------------------------
	{
		"sontungexpt/stcursorword",
		init = function() load_on_file_open("stcursorword") end,
		config = function(_, opts) require("stcursorword").setup {} end,
	},

	{
		"sontungexpt/url-open",
		branch = "mini",
		init = function() plug_loadmap("url-open") end,
		cmd = "URLOpenUnderCursor",
		init = function() load_on_file_open("url-open") end,
		config = function(_, opts) require("url-open").setup {} end,
	},

	{
		"sontungexpt/buffer-closer",
		cmd = "BufferCloserRetire",
		event = { "BufAdd", "FocusLost", "FocusGained" },
		config = function(_, opts) require("buffer-closer").setup {} end,
	},

	{
		"kylechui/nvim-surround",
		keys = { "ys", "ds", "cs" },
		config = function() require("nvim-surround").setup {} end,
	},

	{
		"lukas-reineke/indent-blankline.nvim",
		version = "2.20.8",
		init = load_on_file_open("indent-blankline.nvim"),
		opts = require("plugins.configs.indent-blankline"),
		config = function(_, opts)
			vim.wo.colorcolumn = "99999"
			require("indent_blankline").setup(opts)
		end,
	},

	{
		"brenoprata10/nvim-highlight-colors",
		cmd = "HighlightColorsOn",
		opts = require("plugins.configs.highlight-colors"),
		config = function(_, opts) require("nvim-highlight-colors").setup(opts) end,
	},

	{
		"uga-rosa/ccc.nvim",
		cmd = "CccPick",
		config = function() require("ccc").setup {} end,
	},

	{
		"iamcco/markdown-preview.nvim",
		ft = "markdown",
		build = function() vim.fn["mkdp#util#install"]() end,
	},

	{
		"folke/which-key.nvim",
		keys = { "<leader>", "[", "]", '"', "'", "c", "v", "g", "d" },
		opts = require("plugins.configs.whichkey"),
		config = function(_, opts) require("which-key").setup(opts) end,
	},

	{
		"kevinhwang91/nvim-ufo",
		keys = {
			{ "zc", mode = "n", desc = "Fold current line" },
			{ "zo", mode = "n", desc = "Unfold current line" },
			{ "za", mode = "n", desc = "Toggle fold current line" },
			{ "zA", mode = "n", desc = "Toggle fold all lines" },
			{ "zr", mode = "n", desc = "Unfold all lines" },
			{ "zR", mode = "n", desc = "Fold all lines" },
		},
		dependencies = "kevinhwang91/promise-async",
		opts = require("plugins.configs.nvim-ufo"),
		config = function(_, opts)
			vim.o.foldenable = true -- enable folding when plugin is loaded
			require("ufo").setup(opts)
		end,
	},

	-- {
	-- 	"zbirenbaum/copilot.lua",
	-- 	build = ":Copilot",
	-- 	cmd = "Copilot",
	-- 	event = "InsertEnter",
	-- 	opts = require("plugins.configs.copilot"),
	-- 	config = function(_, opts) require("copilot").setup(opts) end,
	-- },
	--------------------------------------------------- File Explorer ---------------------------------------------------
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		init = function() plug_loadmap("nvim-tree.lua") end,
		cmd = {
			"NvimTreeToggle",
			"NvimTreeFocus",
			"NvimTreeOpen",
		},
		opts = require("plugins.configs.nvim-tree"),
		config = function(_, opts) require("nvim-tree").setup(opts) end,
	},

	{
		"nvim-telescope/telescope.nvim",
		cmd = "Telescope",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
			"nvim-lua/plenary.nvim",

			-- extensions
			"nvim-telescope/telescope-media-files.nvim",
			"nvim-telescope/telescope-fzy-native.nvim",
		},
		init = function() plug_loadmap("telescope.nvim") end,
		opts = function() return require("plugins.configs.telescope") end,
		config = function(_, opts)
			local telescope = require("telescope")
			telescope.setup(opts)
			for _, ext in ipairs(opts.extensions_list) do
				telescope.load_extension(ext)
			end
		end,
	},

	--------------------------------------------------- Comments ---------------------------------------------------
	{
		"numToStr/Comment.nvim",
		dependencies = {
			{
				"JoosepAlviste/nvim-ts-context-commentstring",
				dependencies = {
					"nvim-treesitter/nvim-treesitter",
				},
			},
		},
		keys = {
			{ "gcc", mode = "n", desc = "Comment toggle current line" },
			{ "gc", mode = { "n", "o" }, desc = "Comment toggle linewise" },
			{ "gc", mode = "x", desc = "Comment toggle linewise (visual)" },
			{ "gbc", mode = "n", desc = "Comment toggle current block" },
			{ "gb", mode = { "n", "o" }, desc = "Comment toggle blockwise" },
			{ "gb", mode = "x", desc = "Comment toggle blockwise (visual)" },
		},
		-- because prehook is call so it need to return from a function
		opts = function() return require("plugins.configs.comment.Comment") end,
		config = function(_, opts) require("Comment").setup(opts) end,
	},

	{
		"folke/todo-comments.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		init = function() load_on_file_open("todo-comments.nvim") end,
		config = function() require("todo-comments").setup {} end,
		-- opts = require("plugins.configs.comment.todo-comments"),
		-- config = function(_, opts) require("todo-comments").setup(opts) end,
	},

	--------------------------------------------------- Git supporter ---------------------------------------------------
	{
		"lewis6991/gitsigns.nvim",
		ft = { "gitcommit" },
		init = function() load_on_repo_open("gitsigns.nvim") end,
		opts = require("plugins.configs.git.gitsigns"),
		config = function(_, opts)
			require("gitsigns").setup(opts)
			-- vim.api.nvim_command([[set statusline+=%{get(b:,'gitsigns_status','')}]])
		end,
	},

	{
		"akinsho/git-conflict.nvim",
		ft = { "gitcommit" },
		init = function() load_on_repo_open("git-conflict.nvim") end,
		opts = require("plugins.configs.git.git-conflict"),
		config = function(_, opts) require("git-conflict").setup(opts) end,
	},

	--------------------------------------------------- LSP ---------------------------------------------------
	{
		"neovim/nvim-lspconfig",
		init = function() load_on_file_open("nvim-lspconfig") end,
		config = function() require("plugins.configs.lsp.lspconfig") end,
	},

	{
		"glepnir/lspsaga.nvim",
		event = "LspAttach",
		dependencies = {
			{ "nvim-tree/nvim-web-devicons" },
			--Please make sure you install markdown and markdown_inline parser
			{ "nvim-treesitter/nvim-treesitter" },
		},
		opts = require("plugins.configs.lsp.lspsaga"),
		config = function(_, opts) require("lspsaga").setup(opts) end,
	},

	{
		"williamboman/mason.nvim",
		build = ":MasonUpdate",
		cmd = {
			"Mason",
			"MasonShowInstalledPackages",
			"MasonShowEnsuredPackages",
			"MasonInstall",
			"MasonUninstall",
			"MasonUninstallAll",
			"MasonUpdate",
			"MasonLog",
		},
		opts = function() return require("plugins.configs.mason") end,
		config = function(_, opts) require("mason").setup(opts) end,
	},

	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			{
				-- snippet plugin
				"L3MON4D3/LuaSnip",
				dependencies = "rafamadriz/friendly-snippets",
				config = function() require("plugins.configs.cmp.LuaSnip") end,
			},

			-- cmp sources plugins
			{
				"saadparwaiz1/cmp_luasnip",
				"hrsh7th/cmp-nvim-lua",
				"hrsh7th/cmp-nvim-lsp",
				"hrsh7th/cmp-buffer",
				"hrsh7th/cmp-path",
			},
		},
		config = function() require("plugins.configs.cmp") end,
	},

	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		opts = require("plugins.configs.lsp.conform"),
		---@diagnostic disable-next-line: different-requires
		config = function(_, opts) require("conform").setup(opts) end,
	},

	--------------------------------------------------- Debugger  ---------------------------------------------------
	{
		"rcarriga/nvim-dap-ui",
		dependencies = {
			{
				"mfussenegger/nvim-dap",
				dependencies = {
					{
						"theHamsta/nvim-dap-virtual-text",
						config = function() require("nvim-dap-virtual-text").setup {} end,
						-- config = function() require("dap-virtual-text") end,
					},
				},
				config = function() require("plugins.configs.dap") end,
			},
		},
		keys = {
			{
				"<leader>du",
				function() require("dapui").toggle {} end,
				desc = "Dap UI",
			},
			{
				"<leader>db",
				function() require("dap").toggle_breakpoint() end,
				desc = "Dap Breakpoint",
			},
		},
		config = function() require("plugins.configs.dap.dapui") end,
	},
}

require("lazy").setup(plugins, require("plugins.configs.lazy-nvim"))
