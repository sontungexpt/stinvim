local require = require

local plugins = {
	--------------------------------------------------- Theme ---------------------------------------------------
	{
		"sontungexpt/witch",
		priority = 1000,
		lazy = false,
		-- opts = require("plugins.configs.stinvimui"),
		config = function(_, opts)
			---@diagnostic disable-next-line: different-requires
			require("witch").setup()
		end,
	},

	{
		"sontungexpt/sttusline",
		branch = "develop",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		event = "User FilePostLazyLoaded",
		config = function(_, opts) require("sttusline").setup() end,
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
		"HiPhish/rainbow-delimiters.nvim",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
		event = "User FilePostLazyLoaded",
	},

	{
		"nvim-treesitter/nvim-treesitter",
		event = { "BufReadPost", "BufNewFile" },
		cmd = {
			"TSInstall",
			"TSBufEnable",
			"TSBufDisable",
			"TSModuleInfo",
			"TSInstallFromGrammar",
		},
		build = ":TSUpdate",
		opts = require("plugins.configs.nvim-treesitter"),
		config = function(_, opts) require("nvim-treesitter.configs").setup(opts) end,
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
		event = "User FilePostLazyLoaded",
		config = function(_, opts) require("stcursorword").setup {} end,
	},

	{
		"sontungexpt/url-open",
		branch = "mini",
		cmd = "URLOpenUnderCursor",
		event = "User FilePostLazyLoaded",
		config = function(_, opts) require("url-open").setup() end,
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
		opts = require("plugins.configs.toggleterm"),
		config = function(_, opts) require("toggleterm").setup(opts) end,
	},

	{
		"kylechui/nvim-surround",
		keys = { "ys", "ds", "cs" },
		---@diagnostic disable-next-line: missing-fields
		config = function() require("nvim-surround").setup {} end,
	},

	{
		"windwp/nvim-autopairs",
		opts = require("plugins.configs.nvim-autopairs"),
		event = "InsertEnter",
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
		event = "User FilePostLazyLoaded",
		opts = require("plugins.configs.indent-blankline"),
		config = function(_, opts) require("ibl").setup(opts) end,
	},

	{
		"sontungexpt/nvim-highlight-colors",
		cmd = "HighlightColorsOn",
		event = "User FilePostLazyLoaded",
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

	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		opts = require("plugins.configs.copilot"),
		config = function(_, opts) require("copilot").setup(opts) end,
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
				config = function()
					require("ts_context_commentstring").setup {
						enable_autocmd = false,
					}
				end,
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
		event = "User FilePostLazyLoaded",
		config = function() require("todo-comments").setup {} end,
		-- opts = require("plugins.configs.comment.todo-comments"),
		-- config = function(_, opts) require("todo-comments").setup(opts) end,
	},

	--------------------------------------------------- Git supporter ---------------------------------------------------
	{
		"lewis6991/gitsigns.nvim",
		ft = { "gitcommit" },
		event = "User GitLazyLoaded",
		opts = require("plugins.configs.git.gitsigns"),
		config = function(_, opts) require("gitsigns").setup(opts) end,
	},

	{
		"akinsho/git-conflict.nvim",
		ft = { "gitcommit" },
		event = "User GitLazyLoaded",
		opts = require("plugins.configs.git.git-conflict"),
		config = function(_, opts) require("git-conflict").setup(opts) end,
	},

	--------------------------------------------------- LSP ---------------------------------------------------
	{
		"neovim/nvim-lspconfig",
		event = "User FilePostLazyLoaded",
		config = function() require("plugins.configs.lsp.lspconfig") end,
	},

	{
		"mfussenegger/nvim-jdtls",
		ft = "java",
		-- config is in ftplugin/java.lua
	},

	{
		"glepnir/lspsaga.nvim",
		cmd = "Lspsaga",
		keys = {
			{
				"[e",
				function()
					require("utils").load_and_exec(
						"lspsaga.diagnostic",
						function(diagnostic) diagnostic:goto_prev { severity = vim.diagnostic.severity.ERROR } end
					)
				end,
				desc = "Lspsaga diagnostic goto prev error",
			},
			{
				"]e",
				function()
					require("utils").load_and_exec(
						"lspsaga.diagnostic",
						function(diagnostic) diagnostic:goto_next { severity = vim.diagnostic.severity.ERROR } end
					)
				end,
				desc = "Lspsaga diagnostic goto next error",
			},
		},
		dependencies = {
			{ "neovim/nvim-lspconfig" },
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
		init = function() require("plugins.extensions.mason").extend_command() end,
		cmd = {
			"Mason",
			"MasonLog",
			"MasonUpdate",
			"MasonInstall",
			"MasonUninstall",
			"MasonUninstallAll",
		},
		opts = require("plugins.configs.mason"),
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
