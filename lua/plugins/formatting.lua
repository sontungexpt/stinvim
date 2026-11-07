local vim = vim

local api = vim.api
local bo = vim.bo

-- ============================================================================
-- Constants
-- ============================================================================

local MAX_FORMAT_LINE_COUNT = 10000
local FORMAT_TIMEOUT_MS = 1200

--- Filetypes that should not be formatted automatically.
local DISABLED_AUTO_FORMAT_FILETYPES = {}

-- Filetypes formatted after saving because their formatters may be slower.
local ENABLED_FORMAT_AFTER_SAVE_FILETYPES = {
	-- python = true,
}

-- ============================================================================
-- Formatter groups
-- ============================================================================

-- JavaScript / TypeScript / JSON / CSS
local WEB_FORMATTERS = {
	"oxfmt",
	"biome",
	"prettierd",
	"prettier",
	stop_after_first = true,
}

-- HTML / Markdown / YAML / TOML
local GENERAL_FORMATTERS = {
	"oxfmt",
	"prettierd",
	"prettier",
	stop_after_first = true,
}

-- ============================================================================
-- Format callbacks
-- ============================================================================

local FORMAT_ON_SAVE_CONFIG = {
	timeout_ms = FORMAT_TIMEOUT_MS,
	lsp_format = "fallback",
}

--- Format before saving, skipping excessively large buffers and disabled buffers.
---@param bufnr integer
---@return table|nil
local function format_on_save(bufnr)
	if
		vim.g.disabled_auto_format
		or vim.b[bufnr].disabled_auto_format
		or DISABLED_AUTO_FORMAT_FILETYPES[bo[bufnr].filetype]
		or api.nvim_buf_line_count(bufnr) > MAX_FORMAT_LINE_COUNT
	then
		return
	end

	return FORMAT_ON_SAVE_CONFIG
end

local FORMAT_AFTER_SAVE_CONFIG = {
	lsp_format = "fallback",
}
--- Format selected filetypes after saving (for slow formatters).
---@param bufnr integer
---@return table|nil
local function format_after_save(bufnr)
	if
		vim.g.disabled_auto_format
		or vim.b[bufnr].disabled_auto_format
		or DISABLED_AUTO_FORMAT_FILETYPES[bo[bufnr].filetype]
		or not ENABLED_FORMAT_AFTER_SAVE_FILETYPES[bo[bufnr].filetype]
	then
		return
	end

	return FORMAT_AFTER_SAVE_CONFIG
end

-- ============================================================================
-- ConformFormat user command
-- ============================================================================
api.nvim_create_user_command("ConformToggleAutoFormat", function(args)
	if args.bang then
		-- ConformToggleAutoFormat! will disable formatting just for this buffer
		vim.b.disabled_auto_format = not vim.b.disabled_auto_format
	else
		vim.g.disabled_auto_format = not vim.g.disabled_auto_format
	end
end, {
	desc = "Conform toggle auto format",
	bang = true,
})

api.nvim_create_user_command("ConformFormat", function(args)
	local range

	if args.count ~= -1 then
		local end_line = api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1] or ""

		range = {
			start = { args.line1, 0 },
			["end"] = { args.line2, #end_line },
		}
	end

	require("conform").format {
		async = true,
		lsp_format = "fallback",
		range = range,
	}
end, {
	range = true,
	desc = "Format buffer or selected range",
})

-- ============================================================================
-- Plugin specification
-- ============================================================================

vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
return {
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },

		main = "conform",

		---@module "conform"
		---@type conform.setupOpts
		opts = {
			formatters_by_ft = {
				-- Lua
				lua = { "stylua" },

				-- Python
				python = {
					"ruff_format",
					"autopep8",
					stop_after_first = true,
				},

				-- XML
				xml = { "xmlformatter" },

				-- Go
				go = {
					"goimports",
					"gofumpt",
				},

				-- HTTP
				http = { "kulala-fmt" },
				rest = { "kulala-fmt" },

				-- Kotlin
				kt = { "ktfmt" },

				-- JavaScript / TypeScript
				javascript = WEB_FORMATTERS,
				typescript = WEB_FORMATTERS,
				javascriptreact = WEB_FORMATTERS,
				typescriptreact = WEB_FORMATTERS,

				-- JSON
				json = WEB_FORMATTERS,
				jsonc = WEB_FORMATTERS,

				-- CSS
				css = WEB_FORMATTERS,
				scss = WEB_FORMATTERS,

				-- HTML / Documentation / Configuration
				html = GENERAL_FORMATTERS,
				markdown = GENERAL_FORMATTERS,
				yaml = GENERAL_FORMATTERS,
				toml = GENERAL_FORMATTERS,

				-- C / C++
				c = { "clang_format" },
				cpp = { "clang_format" },

				-- Rust
				rust = {
					"rustfmt",
					"leptosfmt",
					stop_after_first = true,
				},

				-- Zig
				zig = { "zigfmt" },

				-- Shell
				sh = {
					"shfmt",
					stop_after_first = true,
				},
				bash = {
					"shfmt",
					stop_after_first = true,
				},

				-- Java
				java = { "google-java-format" },
			},

			-- ----------------------------------------------------------------
			-- Default formatting behavior
			-- ----------------------------------------------------------------

			default_format_opts = {
				lsp_format = "fallback",
			},

			-- ----------------------------------------------------------------
			-- Save formatting
			-- ----------------------------------------------------------------

			format_on_save = format_on_save,
			format_after_save = format_after_save,

			-- ----------------------------------------------------------------
			-- Logging and notifications
			-- ----------------------------------------------------------------

			log_level = vim.log.levels.ERROR,
			notify_on_error = true,
			notify_no_formatters = true,
		},
	},
}
