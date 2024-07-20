local vim = vim
local api, fn, schedule = vim.api, vim.fn, vim.schedule

local MASONRC_FILE = fn.stdpath("config") .. "/.masonrc.json"
local PACKAGE_DIR = fn.stdpath("data") .. "/mason/packages/"

local M = {
	enabled = true,
}

local get_ensured_packages = function()
	local rcfile = io.open(MASONRC_FILE, "r")
	if rcfile then
		local json = rcfile:read("*all")
		rcfile:close()
		return vim.json.decode(json)
	end
	local ensure_installed = require("mason.settings").current.ensure_installed
	return type(ensure_installed) == "table" and ensure_installed or {}
end

local get_installed_packages = function()
	local installed_packages = {}
	if fn.isdirectory(PACKAGE_DIR) == 1 then
		local package_paths = fn.glob(PACKAGE_DIR .. "/*", true, true)
		for i, path in ipairs(package_paths) do
			installed_packages[i] = fn.fnamemodify(path, ":t")
		end
	end
	return installed_packages
end

local function update_pkgs()
	schedule(function()
		local registry = require("mason-registry")
		registry.update(vim.schedule_wrap(function(success, _)
			if success then
				local installed_pkgs = registry.get_installed_packages()
				for _, pkg in ipairs(installed_pkgs) do
					pkg:check_new_version(function(update_available, version)
						if update_available then
							require("utils.notify").info("Updating" .. pkg.name .. "to" .. version.latest_version)
							pkg:install():on(
								"closed",
								function() require("utils.notify").info("Mason: Update package " .. pkg.name .. " completed") end
							)
							return
						end
					end)
				end
			else
				require("utils.notify").error("Failed to update registries")
			end
		end))
	end)
end

local clean_pkgs = function()
	schedule(function()
		local installed_packages = get_installed_packages()
		local ensured_packages = get_ensured_packages()

		local packages_to_remove = require("utils.tbl").find_unique_array_items(installed_packages, ensured_packages)
		if next(packages_to_remove) then
			pcall(api.nvim_command, "MasonUninstall " .. table.concat(packages_to_remove, " "))
			require("utils").close_buffers_matching("mason", "filetype")
		end
		require("utils.notify").info("Mason: Cleaned packages")
	end)
end

local sync_pkgs = function()
	schedule(function()
		local installed_packages = get_installed_packages()
		local ensured_packages = get_ensured_packages()

		local packages_to_remove = require("utils.tbl").find_unique_array_items(installed_packages, ensured_packages)

		if next(packages_to_remove) and require("mason.settings").current.auto_sync then
			pcall(api.nvim_command, "MasonUninstall " .. table.concat(packages_to_remove, " "))
			require("utils").close_buffers_matching("mason", "filetype")
		end

		schedule(function()
			local packages_to_install = require("utils.tbl").find_unique_array_items(ensured_packages, installed_packages)
			if next(packages_to_install) then
				pcall(api.nvim_command, "MasonInstall " .. table.concat(packages_to_install, " "))
				require("utils").close_buffers_matching("mason", "filetype")

				local count = #packages_to_install
				require("mason-registry"):on("package:install:success", function(pkg)
					require("utils.notify").info("Mason: Installed " .. pkg.name)
					count = count - 1
					if count == 0 then update_pkgs() end
				end)
			end
		end)
	end)
end

-------------------- Auto commands --------------------
M.entry = function()
	api.nvim_create_autocmd("User", {
		once = true,
		pattern = { "VeryLazy", "LazyVimStarted" },
		callback = sync_pkgs,
	})
	api.nvim_create_user_command("MasonSyncPackages", sync_pkgs, { nargs = 0 })
	api.nvim_create_user_command("MasonUpdateAllPackages", update_pkgs, { nargs = 0 })
	api.nvim_create_user_command("MasonCleanPackages", clean_pkgs, { nargs = 0 })
end

return M
