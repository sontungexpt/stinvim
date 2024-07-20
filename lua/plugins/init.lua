local require = require

local plugins = {
	--------------------------------------------------- Theme ---------------------------------------------------
	---
	{
		"sontungexpt/witch",
		priority = 1000,
		lazy = false,
		-- opts = require("config.witch"),
		opts = {},
	},

	{
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
	-- 	opts = require("config.bufferline"),
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
		opts = function() return require("config.nvim-treesitter") end,
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

	-- {
	-- 	"VebbNix/lf-vim",
	-- 	ft = "lf",
	-- },

	------------------------------------ Editor ------------------------------------
	{
		"sontungexpt/stcursorword",
		event = { "CursorHold", "CursorMoved" },
		main = "stcursorword",
		opts = {},
	},

	{
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
		opts = function() return require("config.toggleterm") end,
	},

	{
		"kylechui/nvim-surround",
		keys = { "ys", "ds", "cs" },
		opts = {},
	},

	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		-- opts = function() return require("config.nvim-autopairs") end,
		config = function(_, opts)
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
	-- 	config = function() require("config.wilder") end,
	-- },

	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		event = { "CursorHold", "CursorMoved" },
		dependencies = {
			"HiPhish/rainbow-delimiters.nvim",
		},
		opts = {
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
		},
		config = function(_, opts)
			local hooks = require("ibl.hooks")
			hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
			require("ibl").setup(opts)
		end,
	},

	{
		"brenoprata10/nvim-highlight-colors",
		cmd = "HighlightColors",
		event = { "CursorHold", "CursorMoved" },
		opts = function() return require("config.highlight-colors") end,
		config = function(_, opts)
			require("nvim-highlight-colors").setup(opts)
			vim.api.nvim_command("HighlightColors On")
		end,
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

	{
		"folke/which-key.nvim",
		keys = { "<leader>", "[", "]", '"', "'", "c", "v", "g", "d" },
		main = "which-key",
		opts = function() return require("config.whichkey") end,
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
		opts = function()
			vim.o.foldenable = true -- enable folding when plugin is loaded
			return require("config.nvim-ufo")
		end,
	},

	-- {
	-- 	"zbirenbaum/copilot.lua",
	-- 	cmd = "Copilot",
	-- 	event = "InsertEnter",
	-- 	opts = function() return require("config.copilot") end,
	-- 	config = function(_, opts) require("copilot").setup(opts) end,
	-- },

	{
		"Exafunction/codeium.vim",
		keys = "<A-CR>",
		event = "InsertEnter",
		cmd = "Codeium",
		config = function()
			if vim.fn.filereadable(vim.fn.expand("$HOME") .. "/.codeium/config.json") == 0 then
				vim.api.nvim_command("Codeium Auth")
			end

			vim.g.codeium_no_map_tab = true
			local map = require("utils.mapper").map
			map("i", "<A-Tab>", "codeium#Accept()", 7)
			map({ "n", "i" }, "<A-CR>", "codeium#Chat()", 7)
		end,
	},

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
		opts = function() return require("config.nvim-tree") end,
		config = function(_, opts) require("nvim-tree").setup(opts) end,
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
		opts = function() return require("config.telescope") end,
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
		opts = function() return require("config.comment.Comment") end,
	},

	{
		"folke/todo-comments.nvim",
		cmd = { "TodoQuickFix", "TodoTelescope" },
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		event = { "CursorHold", "CmdlineEnter", "CursorMoved" },
		-- opts = require("config.comment.todo-comments"),
		main = "todo-comments",
		opts = {},
	},

	--------------------------------------------------- Git supporter ---------------------------------------------------
	{
		"lewis6991/gitsigns.nvim",
		event = "User GitLazyLoaded",
		main = "gitsigns",
		opts = function() return require("config.git.gitsigns") end,
	},

	{
		"akinsho/git-conflict.nvim",
		event = "User GitLazyLoaded",
		main = "git-conflict",
		opts = function() return require("config.git.git-conflict") end,
	},

	--------------------------------------------------- LSP ---------------------------------------------------
	{
		"neovim/nvim-lspconfig",
		event = "User FilePostLazyLoaded",
		config = function() require("config.lsp.lspconfig") end,
	},

	{
		"sontungexpt/better-diagnostic-virtual-text",
	},

	{
		"mfussenegger/nvim-jdtls",
		ft = "java",
		-- config is in ftplugin/java.lua
	},

	{
		"akinsho/flutter-tools.nvim",
		ft = "dart",
		event = "BufReadPost */pubspec.yaml",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"stevearc/dressing.nvim", -- optional for vim.ui.select
		},
		main = "flutter-tools",
		opts = function() return require("config.flutter-tools") end,
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
		main = "lspsaga",
		opts = function() return require("config.lsp.lspsaga") end,
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
		main = "mason",
		opts = function() return require("config.mason") end,
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
				config = function() require("config.cmp.LuaSnip") end,
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
		config = function() require("config.cmp") end,
	},

	{
		"stevearc/conform.nvim",
		cmd = "ConformInfo",
		event = "BufWritePre",
		main = "conform",
		opts = function() return require("config.conform") end,
	},

	--------------------------------------------------- Debugger  ---------------------------------------------------
	{
		"rcarriga/nvim-dap-ui",
		dependencies = {
			{
				"mfussenegger/nvim-dap",
				config = function() require("config.dap") end,
			},
			"theHamsta/nvim-dap-virtual-text",
			"nvim-neotest/nvim-nio",
		},
		main = "dapui",
		opts = function() require("config.dap.dapui") end,
	},
}

require("lazy").setup(plugins, require("config.lazy-nvim"))
