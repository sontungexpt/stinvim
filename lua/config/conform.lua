local prettier = { "prettierd", "prettier" }

local options = {
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "autopep8" },
		xml = { "xmlformat" },

		-- webdev
		javascript = { prettier, "eslint" },
		typescript = { prettier, "eslint" },
		javascriptreact = { prettier, "eslint" },
		typescriptreact = { prettier, "eslint" },
		json = { prettier, "eslint" },
		jsonc = { prettier, "eslint" },
		css = { prettier, "eslint" },
		html = { prettier, "eslint" },
		markdown = { prettier, "eslint", "codespell" },
		yaml = { prettier, "eslint" },

		-- ["*"] = { "codespell" },
		c = { "clang_format" },
		cpp = { "clang_format" },
		cmake = { "clang_format" },
		rust = { "rustfmt" },
		zig = { "zigfmt" },

		sh = { "shfmt", "shellcheck" },

		toml = { "taplo" },

		java = { "google-java-format" },

		-- dart = { "dcm_format" },
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
