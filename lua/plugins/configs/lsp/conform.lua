local prettier = { "prettierd", "prettier" }
local options = {
	formatters_by_ft = {
		lua = { "stylua" },
		luau = { "stylua" },

		python = { "autopep8" },

		-- webdev
		javascript = { prettier },
		typescript = { prettier },
		javascriptreact = { prettier },
		typescriptreact = { prettier },
		json = { prettier },
		jsonc = { prettier },
		css = { prettier },
		html = { prettier },
		markdown = { prettier },

		["*"] = { "codespell" },
		c = { "clang_format" },
		cpp = { "clang_format" },
		cmake = { "clang_format" },

		rust = { "rustfmt" },

		sh = { "shfmt" },
		bash = { "shfmt" },
		zsh = { "shfmt" },

		toml = { "taplo" },
	},
}

return options
