local prettier = { "prettierd", "prettier" }

local options = {
	formatters_by_ft = {
		lua = { "stylua" },
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

		sh = { "shfmt", "shellcheck" },

		toml = { "taplo" },

		java = { "google-java-format" },
	},
	format_on_save = {
		timeout_ms = 500,
		lsp_fallback = true,
	},
	format_after_save = {
		lsp_fallback = true,
	},
}

return options
