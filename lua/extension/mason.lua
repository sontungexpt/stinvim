local vim, require = vim, require
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

local caculate_pkgs = function()
	local ensure_pkgs = get_ensured_packages()
	local installed_pkgs = get_installed_packages()

	local ensure_pkgs_size = #ensure_pkgs
	local installed_pkgs_size = #installed_pkgs

	if ensure_pkgs_size == 0 or installed_pkgs_size == 0 then
		return installed_pkgs, installed_pkgs_size, ensure_pkgs, ensure_pkgs_size
	end

	local ensure_pkgs_map = {}
	for i = 1, ensure_pkgs_size do
		ensure_pkgs_map[ensure_pkgs[i]] = true
	end

	local pkgs_to_remove = {}
	local pkgs_to_remove_size = 0

	for i = 1, installed_pkgs_size do
		local pkg = installed_pkgs[i]
		if not ensure_pkgs_map[pkg] then
			pkgs_to_remove_size = pkgs_to_remove_size + 1
			pkgs_to_remove[pkgs_to_remove_size] = pkg
		else
			ensure_pkgs_map[pkg] = nil
		end
	end

	local pkgs_to_install = {}
	local pkgs_to_install_size = 0

	for pkg, _ in pairs(ensure_pkgs_map) do
		pkgs_to_install_size = pkgs_to_install_size + 1
		pkgs_to_install[pkgs_to_install_size] = pkg
	end

	return pkgs_to_remove, pkgs_to_remove_size, pkgs_to_install, pkgs_to_install_size
end

--- Update all packages
--- @param exclued table<string,true> packages to be excluded from updating process. Key is package name and value is true
local update_pkgs = function(exclued)
	schedule(function()
		require("utils").load_mod("mason-registry", function(registry)
			registry.update(vim.schedule_wrap(function(success, _)
				if success then
					local installed_pkgs = registry.get_installed_packages()
					for _, pkg in ipairs(installed_pkgs) do
						local pkg_name = pkg.name
						if not exclued or not exclued[pkg_name] then
							pkg:check_new_version(function(update_available, version)
								if update_available then
									local latest_version = version.latest_version
									require("utils.notify").info("Updating" .. pkg_name .. "to" .. latest_version)
									pkg:install():on(
										"closed",
										function()
											require("utils.notify").info(
												"Mason: Update package " .. pkg_name .. "to version " .. latest_version .. " completed"
											)
										end
									)
									return
								end
							end)
						end
					end
				else
					require("utils.notify").error("Failed to update registries")
				end
			end))
		end)
	end)
end

local clean_pkgs = function()
	schedule(function()
		local packages_to_remove =
			require("utils.tbl").find_unique_array_items(get_installed_packages(), get_ensured_packages())
		if next(packages_to_remove) then
			pcall(api.nvim_command, "MasonUninstall " .. table.concat(packages_to_remove, " "))
			require("utils.notify").info("Mason: Cleaned packages")
		end
	end)
end

--- @param package_names string[]
--- @return string[] valid package names
--- @return number size of valid packages
local filter_valid_packages = function(package_names)
	local registry = require("mason-registry")
	local Func = require("mason-core.functional")
	local Package = require("mason-core.package")

	local size = 0

	return Func.filter(function(pkg_specifier)
		local package_name = Package.Parse(pkg_specifier)
		local ok = pcall(registry.get_package, package_name)
		if ok then
			size = size + 1
			return true
		end
		require("utils.notify").error("Mason: " .. pkg_specifier .. " is not a valid package.", { title = "Mason" })
		return false
	end)(package_names),
		size
end

--- Install packagges without any ui open
--- @param package_names string[] packages to be installed
--- @param cb function Args: name, all_completed The callback function will be called when each package is installed successfully
local MasonInstall = function(package_names, cb)
	return require("utils").load_mod("mason-registry", function(registry)
		local Func = require("mason-core.functional")
		local Package = require("mason-core.package")

		local install_packages = Func.map(function(pkg_specifier)
			local package_name, version = Package.Parse(pkg_specifier)
			local pkg = registry.get_package(package_name)
			return pkg:install {
				version = version,
				force = true,
				strict = true,
				debug = false,
			}
		end)

		local valid_packages, valid_packages_size
		registry.refresh(function()
			valid_packages, valid_packages_size = filter_valid_packages(package_names)
			install_packages(valid_packages)
		end)

		registry:on("package:install:success", function(pkg)
			local pkg_name = pkg.name
			require("utils.notify").info("Mason: Install package " .. pkg_name .. " completed")
			valid_packages_size = valid_packages_size - 1
			if type(cb) == "function" then cb(pkg_name, valid_packages_size == 0) end
			cb(pkg_name, valid_packages_size == 0)
		end)
	end)
end

--- Uninstall packagges without any ui open
--- @param package_names string[] packages to be uninstalled
--- @param cb ? function Args: name, all_completed The callback function will be called when each package is uninstalled
local function MasonUninstall(package_names, cb)
	return require("utils").load_mod("mason-registry", function(registry)
		local Func = require("mason-core.functional")
		local valid_packages, valid_packages_size = filter_valid_packages(package_names)
		if valid_packages_size > 0 then
			Func.each(function(package_name)
				local pkg = registry.get_package(package_name)
				pkg:uninstall()
			end, valid_packages)

			registry:on("package:uninstall:success", function(pkg)
				local pkg_name = pkg.name
				require("utils.notify").info("Mason: Uninstall package " .. pkg_name .. " completed")
				valid_packages_size = valid_packages_size - 1
				if type(cb) == "function" then cb(pkg_name, valid_packages_size == 0) end
			end)
		end
	end)
end

local sync_pkgs = function()
	schedule(function()
		local pkgs_to_remove, pkgs_to_remove_size, pkgs_to_install, pkgs_to_install_size = caculate_pkgs()

		if pkgs_to_remove_size > 0 and require("mason.settings").current.auto_sync then MasonUninstall(pkgs_to_remove) end

		schedule(function()
			if pkgs_to_install_size > 0 then
				local exclued_update_pkgs = {}
				MasonInstall(pkgs_to_install, function(pkg_name, all_completed)
					exclued_update_pkgs[pkg_name] = true
					if all_completed then update_pkgs(exclued_update_pkgs) end
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
	api.nvim_create_user_command("MasonUpdatePackages", update_pkgs, { nargs = 0 })
	api.nvim_create_user_command("MasonCleanPackages", clean_pkgs, { nargs = 0 })
end

return M
