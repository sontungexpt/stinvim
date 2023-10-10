local api = vim.api
local fn = vim.fn
local utils = require("utils")
local schedule = vim.schedule
local mason_configs = require("plugins.configs.lsp.mason")

local M = {}

M.get_installed_packages = function()
	local installed_packages = {}
	local package_path = fn.stdpath("data") .. "/mason/packages/"
	if fn.isdirectory(package_path) == 1 then
		local package_dirs = fn.glob(package_path .. "/*", true, true)
		for _, package_dir in ipairs(package_dirs) do
			local package_name = fn.fnamemodify(package_dir, ":t")
			table.insert(installed_packages, package_name)
		end
	end
	return installed_packages
end

M.had_changed = function()
	return not utils.is_same_array(mason_configs.ensure_installed, M.get_installed_packages())
end

M.sync_packages = function()
	local installed_packages = M.get_installed_packages()
	local packages_to_remove = utils.find_unique_items(installed_packages, mason_configs.ensure_installed)
	local packages_to_install = utils.find_unique_items(mason_configs.ensure_installed, installed_packages)

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

-------------------- Auto commands --------------------
M.create_autocmds = function()
	api.nvim_create_autocmd("User", {
		group = api.nvim_create_augroup("MasonSyncPackage", { clear = true }),
		pattern = "VeryLazy",
		callback = function()
			schedule(function()
				if utils.is_plug_installed("mason", "/") and mason_configs.auto_sync then
					if M.had_changed() then M.sync_packages() end
				end
			end)
		end,
	})
end

return M
