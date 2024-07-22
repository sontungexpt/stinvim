---@param bufnr integer
---@param ... string
---@return string
local function first(bufnr, ...)
	local conform = require("conform")
	for i = 1, select("#", ...) do
		local formatter = select(i, ...)
		if conform.get_formatter_info(formatter, bufnr).available then return formatter end
	end
	return select(1, ...)
end

local prettier_eslint = function(bufnr) return { first(bufnr, "prettierd", "prettier"), "eslint_d" } end

local slow_format_filetypes = {}

local options = {
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "autopep8" },
		xml = { "xmlformat" },

		-- webdev
		javascript = prettier_eslint,
		typescript = prettier_eslint,
		javascriptreact = prettier_eslint,
		typescriptreact = prettier_eslint,
		json = prettier_eslint,
		jsonc = prettier_eslint,
		css = prettier_eslint,
		html = prettier_eslint,
		markdown = function(bufnr) return { prettier_eslint(bufnr), "codespell" } end,
		yaml = prettier_eslint,

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

	default_format_opts = {
		lsp_format = "fallback",
	},
	format_on_save = function(bufnr)
		if slow_format_filetypes[vim.bo[bufnr].filetype] then return end
		local function on_format(err)
			if err and err:match("timeout$") then slow_format_filetypes[vim.bo[bufnr].filetype] = true end
		end
		return { timeout_ms = 500, lsp_format = "fallback" }, on_format
	end,

	format_after_save = function(bufnr)
		if not slow_format_filetypes[vim.bo[bufnr].filetype] then return end
		return { lsp_format = "fallback" }
	end,
}

return options
