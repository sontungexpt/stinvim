local no_seps = require("configs.lualine.seps").no_seps

-- Components
local file = require("config.lualine.components.file")
local mode = require("config.lualine.components.mode")
local indent = require("config.lualine.components.indent")
local copilot = require("config.lualine.components.copilot")
local location = require("config.lualine.components.location")
local lsp_servers = require("config.lualine.components.lsp_servers")
local encoding = require("config.lualine.components.encoding")
local diagnostics = require("config.lualine.components.diagnostics")
local git = require("config.lualine.components.git")

local configs = {
	options = {
		theme = "tokyonight",
		globalstatus = true,
		icons_enabled = true,
		component_separators = no_seps,
		section_separators = no_seps,
		disabled_filetypes = {
			"lazy",
			"NvimTree",
			"mason",
			"toggleterm",
			"help",
			"TelescopePrompt",
		},
		always_divide_middle = true,
	},
	sections = {
		lualine_a = {
			mode,
		},
		lualine_b = {
			file.type,
			file.name,
		},
		lualine_c = {
			git.branch,
			git.diff,
		},
		lualine_x = {
			diagnostics,
			lsp_servers,
			copilot,
			indent.icon,
			indent.value,
		},
		lualine_y = {
			encoding,
		},
		lualine_z = {
			location.value,
			location.progress,
		},
	},
}

return configs
