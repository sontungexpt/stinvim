local no_seps = require("configs.lualine.seps").no_seps

-- Components
local file = require("plugins.configs.lualine.components.file")
local mode = require("plugins.configs.lualine.components.mode")
local indent = require("plugins.configs.lualine.components.indent")
local copilot = require("plugins.configs.lualine.components.copilot")
local location = require("plugins.configs.lualine.components.location")
local lsp_servers = require("plugins.configs.lualine.components.lsp_servers")
local encoding = require("plugins.configs.lualine.components.encoding")
local diagnostics = require("plugins.configs.lualine.components.diagnostics")
local git = require("plugins.configs.lualine.components.git")

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
