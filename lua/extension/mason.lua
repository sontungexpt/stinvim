local vim = vim
local api, fn, schedule = vim.api, vim.fn, vim.schedule
local MASON_CONFIG_MODULE = "plugins.configs.mason"
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

local function update_all_packages()
	schedule(function()
		local registry = require("mason-registry")
		registry.update(vim.schedule_wrap(function(success, updated_registries)
			if success then
				local installed_pkgs = registry.get_installed_packages()
				local running = #installed_pkgs

				if running > 0 then
					local updated = false
					for _, pkg in ipairs(installed_pkgs) do
						pkg:check_new_version(function(update_available, version)
							if update_available then
								require("utils.notify").info("Updating" .. pkg.name .. "to" .. version.latest_version)

								pkg:install():on("closed", function()
									updated = true
									running = running - 1
									if running == 0 then require("utils.notify").info("Mason: Update all packages completed") end
								end)
								return
							end
							running = running - 1
						end)
					end

					if running == 0 then
						if updated then
							require("utils.notify").info("Mason: Update all packages completed")
						else
							require("utils.notify").info("Mason: All packages are up to date")
						end
					end
				end
			else
				require("utils.notify").error("Failed to update registries")
			end
		end))
	end)
end

local sync_packages = function()
	schedule(function()
		local utils = require("utils")
		if utils.is_plug_installed("mason", "/") then
			local installed_packages = get_installed_packages()
			local ensured_packages = get_ensured_packages()

			local packages_to_remove = require("utils.tbl").find_unique_array_items(installed_packages, ensured_packages)
			local uninstall_trigger = false

			if next(packages_to_remove) then
				pcall(api.nvim_command, "MasonUninstall " .. table.concat(packages_to_remove, " "))
				uninstall_trigger = true
			end

			schedule(function()
				local packages_to_install = require("utils.tbl").find_unique_array_items(ensured_packages, installed_packages)
				if next(packages_to_install) then
					pcall(api.nvim_command, "MasonInstall " .. table.concat(packages_to_install, " "))

					local count = #packages_to_install
					require("mason-registry"):on("package:install:success", function(pkg)
						count = count - 1
						if count == 0 then
							if not uninstall_trigger then
								require("utils.notify").info("Mason: Installed ensured packages successfully")
							else
								require("utils.notify").info("Mason: Sync packages successfully")
							end
							utils.close_buffers_matching("mason", "filetype")
							update_all_packages()
						end
					end)
				elseif uninstall_trigger then
					update_all_packages()
					utils.close_buffers_matching("mason", "filetype")
					require("utils.notify").info("Mason: Removing unused packages successfully")
				end
			end)
		end
	end)
end

-------------------- Auto commands --------------------
M.entry = function()
	api.nvim_create_user_command("MasonSyncPackages", sync_packages, { nargs = 0 })
	api.nvim_create_user_command("MasonUpdateAllPackages", update_all_packages, { nargs = 0 })

	api.nvim_create_autocmd("User", {
		once = true,
		pattern = { "VeryLazy", "LazyVimStarted" },
		callback = function()
			if require(MASON_CONFIG_MODULE).auto_sync then sync_packages() end
		end,
	})
end

return M
