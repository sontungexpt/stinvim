local vim = vim
local api, fn, schedule = vim.api, vim.fn, vim.schedule

local MASON_CONFIG_MODULE = "plugins.configs.mason"
local MASONRC_FILE = fn.stdpath("config") .. "/.masonrc.json"
local PACKAGE_DIR = fn.stdpath("data") .. "/mason/packages/"

local M = {}

local get_ensured_packages = function()
	local rcfile = io.open(MASONRC_FILE, "r")
	if rcfile then
		local json = rcfile:read("*all")
		rcfile:close()
		return vim.json.decode(json)
	else
		package.loaded[MASON_CONFIG_MODULE] = nil
		local status_ok, config = pcall(require, MASON_CONFIG_MODULE)
		return status_ok and config.ensure_installed or {}
	end
end

local get_installed_packages = function()
	if fn.isdirectory(PACKAGE_DIR) == 1 then
		local package_paths = fn.glob(PACKAGE_DIR .. "/*", true, true)
		return vim.tbl_map(function(path) return fn.fnamemodify(path, ":t") end, package_paths)
	end
	return {}
end

local sync_packages = function()
	local utils = require("utils")
	if utils.is_plug_installed("mason", "/") then
		local installed_packages = get_installed_packages()
		local ensured_packages = get_ensured_packages()

		schedule(function()
			local packages_to_remove = utils.find_unique_items(installed_packages, ensured_packages)
			if #packages_to_remove > 0 then
				api.nvim_command("MasonUninstall " .. table.concat(packages_to_remove, " "))
			end
			schedule(function()
				local packages_to_install = utils.find_unique_items(ensured_packages, installed_packages)
				if #packages_to_install > 0 then
					api.nvim_command("MasonInstall " .. table.concat(packages_to_install, " "))
				end
			end)
		end, 10)
	end
end

M.extend_command = function()
	api.nvim_create_user_command("MasonSyncPackages", sync_packages, { nargs = 0 })
end

-------------------- Auto commands --------------------
M.create_autocmds = function()
	if require(MASON_CONFIG_MODULE).auto_sync then
		api.nvim_create_autocmd("User", {
			group = api.nvim_create_augroup("MasonExtension", { clear = true }),
			pattern = "VeryLazy",
			callback = function() schedule(sync_packages) end,
		})
	end
end

return M
