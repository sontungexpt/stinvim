---@param bufnr integer
---@param ... string
---@return string
---@diagnostic disable: unused-local
---@diagnostic disable-next-line: unused-function
local function first(bufnr, ...)
	local conform = require("conform")
	for i = 1, select("#", ...) do
		local formatter = select(i, ...)
		if conform.get_formatter_info(formatter, bufnr).available then return formatter end
	end
	return select(1, ...)
end

local biome_prettier = { "biome", "prettierd", "prettier", stop_after_first = true }

local prettier = { "prettierd", "prettier", stop_after_first = true }

local slow_format_filetypes = {}

local options = {
	formatters_by_ft = {
		lua = { "stylua" },

		python = { "ruff_format", "autopep8", stop_after_first = true },

		xml = { "xmlformat" },

		go = { "goimports", "gofumpt" },

		-- webdev
		javascript = biome_prettier,
		typescript = biome_prettier,
		javascriptreact = biome_prettier,
		typescriptreact = biome_prettier,
		json = biome_prettier,
		jsonc = biome_prettier,
		css = prettier,
		html = prettier,
		markdown = prettier,
		yaml = prettier,

		-- ["*"] = { "codespell" },
		c = { "clang_format" },
		cpp = { "clang_format" },
		rust = { "rustfmt", "leptosfmt" },
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
