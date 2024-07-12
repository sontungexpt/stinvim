---@diagnostic disable: different-requires
local require = require

local plugins = {
	--------------------------------------------------- Theme ---------------------------------------------------
	---
	{
		"sontungexpt/witch",
		-- dir = "/home/stilux/Data/Workspace/neovim-plugins/witch",
		priority = 1000,
		-- branch = "develop",
		lazy = false,
		-- opts = require("plugins.configs.witch"),
		opts = {},
	},

	-- {
	-- 	"folke/tokyonight.nvim",
	-- 	lazy = false,
	-- 	priority = 1000,
	-- 	opts = function() return require("plugins.configs.tokyonight") end,
	-- 	config = function(_, opts)
	-- 		require("tokyonight").setup(opts)
	-- 		vim.cmd([[colorscheme tokyonight]])
	-- 	end,
	-- },

	-- {
	-- 	dir = "/home/stilux/Data/Workspace/neovim-plugins/witch-line",
	-- 	dependencies = {
	-- 		"nvim-tree/nvim-web-devicons",
	-- 	},
	-- 	init = function() load_on_file_open("witch-line") end,
	-- 	-- opts = require("plugins.configs.sttusline"),
	-- 	config = function(_, opts) require("witch-line").setup(opts) end,
	-- },
	{
		-- dir = "/home/stilux/Data/Workspace/neovim-plugins/sttusline",
		-- event = "UIEnter",
		"sontungexpt/sttusline",
		branch = "develop",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		event = "User FilePostLazyLoaded",
		opts = {},
	},

	-- {
	-- 	"akinsho/bufferline.nvim",
	-- 	dependencies = {
	-- 		"nvim-tree/nvim-web-devicons",
	-- 	},
	-- 	event = "User FilePostLazyLoaded",
	-- 	opts = require("plugins.configs.bufferline"),
	-- 	config = function(_, opts) require("bufferline").setup(opts) end,
	-- },

	--------------------------------------------------- Syntax ---------------------------------------------------
	{
		"nvim-treesitter/nvim-treesitter",
		dependencies = {
			"HiPhish/rainbow-delimiters.nvim",
		},
		event = {
			"CursorHold",
			"CursorMoved",
			"User FilePostLazyLoaded",
		},
		cmd = {
			"TSInstall",
			"TSBufEnable",
			"TSEnable",
			"TSBufDisable",
			"TSModuleInfo",
			"TSInstallFromGrammar",
		},
		build = ":TSUpdate",
		main = "nvim-treesitter.configs",
		opts = function() return require("plugins.configs.nvim-treesitter") end,
	},

	{
		"williamboman/mason.nvim",
		build = ":MasonUpdate",
		cmd = {
			"Mason",
			"MasonLog",
			"MasonUpdate",
			"MasonInstall",
			"MasonUninstall",
			"MasonUninstallAll",
		},
		opts = function() return require("plugins.configs.mason") end,
	},

	-- {
	-- 	"windwp/nvim-ts-autotag",
	-- 	dependencies = {
	-- 		"nvim-treesitter/nvim-treesitter",
	-- 	},
	-- 	ft = {
	-- 		"html",
	-- 		"vue",
	-- 		"tsx",
	-- 		"jsx",
	-- 		"svelte",
	-- 		"javascript",
	-- 		"typescript",
	-- 		"javascriptreact",
	-- 		"typescriptreact",
	-- 	},
	-- },

	{
		"fladson/vim-kitty",
		ft = "kitty",
	},

	{
		"VebbNix/lf-vim",
		ft = "lf",
	},

	{
		"elkowar/yuck.vim",
		ft = "yuck",
	},

	------------------------------------ Editor ------------------------------------
	{
		-- dir = "/home/stilux/Data/Workspace/neovim-plugins/stcursorword",
		"sontungexpt/stcursorword",
		event = { "CursorHold", "CursorMoved" },
		main = "stcursorword",
		opts = {},
	},

	{
		-- dir = "/home/stilux/Data/Workspace/neovim-plugins/url-open",
		"sontungexpt/url-open",
		branch = "mini",
		cmd = "URLOpenUnderCursor",
		event = { "CursorHold", "CursorMoved" },
		main = "url-open",
		opts = {},
	},

	-- {
	-- 	"sontungexpt/buffer-closer",
	-- 	cmd = "BufferCloserRetire",
	-- 	event = { "BufAdd", "FocusLost", "FocusGained" },
	-- 	config = function(_, opts) require("buffer-closer").setup {} end,
	-- },

	{
		"akinsho/toggleterm.nvim",
		cmd = { "ToggleTerm", "ToggleTermToggleAll", "TermExec" },
		keys = "<C-t>",
		main = "toggleterm",
		opts = function() return require("plugins.configs.toggleterm") end,
	},

	{
		"kylechui/nvim-surround",
		keys = { "ys", "ds", "cs" },
		opts = {},
	},

	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		-- opts = function() return require("plugins.configs.nvim-autopairs") end,
		config = function(_, opts)
			---@diagnostic disable-next-line: different-requires
			require("nvim-autopairs").setup(opts)
			local cmp_status_ok, cmp = pcall(require, "cmp")
			local cmp_autopairs_status_ok, cmp_autopairs = pcall(require, "nvim-autopairs.completion.cmp")
			if cmp_status_ok and cmp_autopairs_status_ok then
				cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done { map_char = { tex = "" } })
			end
		end,
	},

	-- {
	-- 	"gelguy/wilder.nvim",
	-- 	dependencies = {
	-- 		"romgrk/fzy-lua-native",
	-- 	},
	-- 	build = ":UpdateRemotePlugins",
	-- 	event = "CmdlineEnter",
	-- 	config = function() require("plugins.configs.wilder") end,
	-- },

	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		event = { "CursorHold", "CursorMoved" },
		dependencies = {
			"HiPhish/rainbow-delimiters.nvim",
		},
		opts = function()
			local hooks = require("ibl.hooks")
			hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)

			return {
				indent = {
					char = "│",
				},
				scope = {
					highlight = {
						"RainbowDelimiterRed",
						"RainbowDelimiterYellow",
						"RainbowDelimiterBlue",
						"RainbowDelimiterOrange",
						"RainbowDelimiterGreen",
						"RainbowDelimiterViolet",
						"RainbowDelimiterCyan",
					},
					char = "│",
				},
			}
		end,
	},

	{
		"sontungexpt/nvim-highlight-colors",
		cmd = "HighlightColorsOn",
		event = "User FilePostLazyLoaded",
		opts = function() return require("plugins.configs.highlight-colors") end,
	},

	{
		"uga-rosa/ccc.nvim",
		cmd = "CccPick",
		main = "ccc",
		opts = {},
	},

	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		ft = { "markdown" },
		build = function() vim.fn["mkdp#util#install"]() end,
		config = function() vim.g.mkdp_auto_close = 1 end,
	},

	-- {
	-- 	"OXY2DEV/markview.nvim",
	-- 	ft = "markdown",
	-- 	dependencies = {
	-- 		"nvim-treesitter/nvim-treesitter",
	-- 		"nvim-tree/nvim-web-devicons",
	-- 	},
	-- },

	{
		"aklt/plantuml-syntax",
		ft = "plantuml",
		event = "BufEnter *.wsd,*.pu,*.puml,*.plantuml",
	},

	{
		"https://gitlab.com/itaranto/plantuml.nvim",
		event = "BufWritePre *.wsd,*.pu,*.puml,*.plantuml",
		cmd = "PlantUml",
		opts = {
			renderer = {
				type = "image",
				options = {
					prog = "feh",
					dark_mode = false,
				},
			},
			render_on_write = true,
		},
		main = "plantuml",
	},

	{
		"folke/which-key.nvim",
		keys = { "<leader>", "[", "]", '"', "'", "c", "v", "g", "d" },
		opts = function() return require("plugins.configs.whichkey") end,
		main = "which-key",
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
		main = "ufo",
		opts = function()
			vim.opt.foldenable = true -- enable folding when plugin is loaded
			return require("plugins.configs.nvim-ufo")
		end,
	},

	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		main = "copilot",
		opts = function() return require("plugins.configs.copilot") end,
	},

	-- {
	-- 	"Exafunction/codeium.vim",
	-- 	keys = "<A-CR>",
	-- 	event = "InsertEnter",
	-- 	cmd = "Codeium",
	-- 	config = function()
	-- 		vim.g.codeium_no_map_tab = true
	-- 		local map = require("utils.mapper").map
	-- 		map("i", "<A-Tab>", "codeium#Accept()", 7)
	-- 		map({ "n", "i" }, "<A-CR>", "codeium#Chat()", 7)
	-- 	end,
	-- },

	--------------------------------------------------- File Explorer ---------------------------------------------------
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		cmd = {
			"NvimTreeToggle",
			"NvimTreeFocus",
			"NvimTreeOpen",
		},
		opts = function() return require("plugins.configs.nvim-tree") end,
		main = "nvim-tree",
	},

	{
		"nvim-telescope/telescope.nvim",
		cmd = "Telescope",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
			"nvim-lua/plenary.nvim",

			-- extensions
			-- "nvim-telescope/telescope-media-files.nvim",
			"nvim-telescope/telescope-fzy-native.nvim",
		},
		opts = function() return require("plugins.configs.telescope") end,
		config = function(_, opts)
			local telescope = require("telescope")
			telescope.setup(opts)
			for _, ext in ipairs(opts.extension_list) do
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
				opts = {
					enable_autocmd = false,
				},
				config = function(_, opts) require("ts_context_commentstring").setup(opts) end,
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
		main = "Comment",
		opts = function() return require("plugins.configs.comment.Comment") end,
	},

	{
		"folke/todo-comments.nvim",
		cmd = { "TodoTelescope", "TodoQuickFix" },
		dependencies = "nvim-lua/plenary.nvim",
		event = { "CursorHold", "CmdlineEnter", "CursorMoved" },
		main = "todo-comments",
		opts = {},
		-- opts = require("plugins.configs.comment.todo-comments"),
	},

	--------------------------------------------------- Git supporter ---------------------------------------------------
	{
		"lewis6991/gitsigns.nvim",
		event = "User GitLazyLoaded",
		opts = function() return require("plugins.configs.git.gitsigns") end,
		main = "gitsigns",
	},

	{
		"akinsho/git-conflict.nvim",
		event = "User GitLazyLoaded",
		opts = function() return require("plugins.configs.git.git-conflict") end,
		main = "git-conflict",
	},

	--------------------------------------------------- LSP ---------------------------------------------------
	{
		"neovim/nvim-lspconfig",
		event = "User FilePostLazyLoaded",
		config = function() require("plugins.configs.lsp.lspconfig") end,
	},

	{
		"sontungexpt/better-diagnostic-virtual-text",
		dir = "/home/stilux/Data/Workspace/neovim-plugins/better-diagnostic-virtual-text",
	},

	{
		-- config is in ftplugin/java.lua
		"mfussenegger/nvim-jdtls",
		ft = "java",
	},

	{
		"akinsho/flutter-tools.nvim",
		ft = "dart",
		event = "BufReadPost */pubspec.yaml",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"stevearc/dressing.nvim", -- optional for vim.ui.select
		},
		opts = function() return require("plugins.configs.flutter-tools") end,
		main = "flutter-tools",
	},

	{
		"glepnir/lspsaga.nvim",
		cmd = "Lspsaga",
		dependencies = {
			"neovim/nvim-lspconfig",
			"nvim-tree/nvim-web-devicons",

			--Please make sure you install markdown and markdown_inline parser
			"nvim-treesitter/nvim-treesitter",
		},
		opts = function() return require("plugins.configs.lsp.lspsaga") end,
		main = "lspsaga",
	},

	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			{
				-- snippet plugin
				"L3MON4D3/LuaSnip",
				build = "make install_jsregexp",
				dependencies = "rafamadriz/friendly-snippets",
				config = function() require("plugins.configs.cmp.LuaSnip") end,
			},

			-- cmp sources plugins
			{
				"hrsh7th/cmp-path",
				"hrsh7th/cmp-buffer",
				"hrsh7th/cmp-nvim-lsp",
				"hrsh7th/cmp-nvim-lua",
				"saadparwaiz1/cmp_luasnip",
			},
		},
		config = function() require("plugins.configs.cmp") end,
	},

	{
		"stevearc/conform.nvim",
		cmd = "ConformInfo",
		event = "BufWritePre",
		opts = function() return require("plugins.configs.conform") end,
		main = "conform",
	},

	--------------------------------------------------- Debugger  ---------------------------------------------------
	{
		"rcarriga/nvim-dap-ui",
		dependencies = {
			{
				"mfussenegger/nvim-dap",
				config = function() require("plugins.configs.dap") end,
			},
			"theHamsta/nvim-dap-virtual-text",
			"nvim-neotest/nvim-nio",
		},
		opts = function() require("plugins.configs.dap.dapui") end,
		main = "dap-ui",
	},
}

require("lazy").setup(plugins, require("plugins.configs.lazy-nvim"))
