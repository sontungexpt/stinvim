local api = vim.api
local fn = vim.fn
local utils = require("utils")
local schedule = vim.schedule
local mason_config_module = "plugins.configs.mason"
local MASONRC_FILE = fn.stdpath("config") .. "/.masonrc.json"
local PACKAGE_DIR = fn.stdpath("data") .. "/mason/packages/"

local M = {}

M.json_to_array = function(json_str)
	local array = {}
	for value in json_str:gmatch('"([^"]+)"') do
		table.insert(array, value)
	end
	return array
end

M.get_ensured_packages = function()
	local rcfile = io.open(MASONRC_FILE, "r")
	if rcfile then
		local json = rcfile:read("*all")
		rcfile:close()
		return M.json_to_array(json)
	else
		package.loaded[mason_config_module] = nil
		local status_ok, config = pcall(require, mason_config_module)
		return status_ok and config.ensure_installed or {}
	end
end

M.get_installed_packages = function()
	if fn.isdirectory(PACKAGE_DIR) == 1 then
		local package_paths = fn.glob(PACKAGE_DIR .. "/*", true, true)
		return vim.tbl_map(function(path) return fn.fnamemodify(path, ":t") end, package_paths)
	end
	return {}
end

M.sync_packages = function()
	if utils.is_plug_installed("mason", "/") then
		local installed_packages = M.get_installed_packages()
		local ensured_packages = M.get_ensured_packages()

		-- had changed
		if not utils.is_same_array(ensured_packages, installed_packages) then
			local packages_to_remove = utils.find_unique_items(installed_packages, ensured_packages)
			local packages_to_install = utils.find_unique_items(ensured_packages, installed_packages)

			vim.defer_fn(function()
				schedule(function()
					if #packages_to_remove > 0 then
						api.nvim_command("MasonUninstall " .. table.concat(packages_to_remove, " "))
					end
				end)
				schedule(function()
					if #packages_to_install > 0 then
						api.nvim_command("MasonInstall " .. table.concat(packages_to_install, " "))
					end
				end)
			end, 10)
		end
	end
end

M.extend_command = function()
	vim.api.nvim_create_user_command("MasonSyncPackages", M.sync_packages, { nargs = 0 })
end

-------------------- Auto commands --------------------
M.create_autocmds = function()
	local group = api.nvim_create_augroup("MasonExtensions", { clear = true })
	if require(mason_config_module).auto_sync then
		api.nvim_create_autocmd("User", {
			group = group,
			pattern = "VeryLazy",
			callback = function(e)
				schedule(function() M.sync_packages() end)
			end,
		})
	end
end

return M
