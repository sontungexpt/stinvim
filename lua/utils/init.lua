local api, fn, pcall = vim.api, vim.fn, pcall

local M = {}

--- Get the root directory of the project.
---
--- @param source string|integer Buffer number (0 for current buffer) or file path to begin the search from
--- @return string|nil: The root directory path of the project
M.find_root = function(source, markers)
	return vim.fs.root(source or 0, markers or vim.g.stinvim_root_markers or {
		".git",
		"package.json", -- npm
		"Cargo.toml", -- rust
		"build.zig", -- zig
		"stylua.toml", -- lua
		"lazy-lock.json", -- nvim config
		"gradlew", -- java
		"mvnw", -- java
	})
end

--- Executes a specified command using vim.api.nvim_command
--- and optionally displays success or error messages.
---
--- @param command string The command to execute
--- @param msg table|nil The message to print on success or error
--- @param quiet boolean|nil Whether to display success or error messages
--- @return boolean True if the command was executed successfully, false otherwise.
M.exec_cmd = function(command, msg, quiet)
	local success, error_message = pcall(api.nvim_command, command)
	if not quiet then
		if success then
			require("utils.notify").info(msg and msg.success or command .. " execute success")
		else
			require("utils.notify").error((msg and msg.error or "Error") .. ": " .. error_message)
		end
	end
	return success
end

--- Checks if a given plugin is installed in the specified directory.
---
--- @param plugin_name string The name of the plugin to check.
--- @param custom_dir string  The custom installation directory for plugins.
--- @return boolean True if the plugin is installed, false otherwise.
M.is_plug_installed = function(plugin_name, custom_dir)
	custom_dir = custom_dir or "/lazy/"
	if not vim.startswith(custom_dir, "/") then custom_dir = "/" .. custom_dir end
	if not vim.endswith(custom_dir, "/") then custom_dir = custom_dir .. "/" end

	return fn.isdirectory(fn.stdpath("data") .. custom_dir .. plugin_name) == 1
end

--- Attempts to load a module and calls a provided callback function with the loaded module if successful.
---
--- @param name string The name of the module to load.
--- @param cb function A function to be executed with the loaded module as an argument.
M.load_mod = function(name, cb)
	local status_ok, module = pcall(require, name)
	if status_ok then
		return cb(module)
	else
		require("utils.notify").error("Module " .. name .. " not found")
	end
end

--- Attempts to load multiple modules and calls a provided callback function with the loaded modules if successful. If a module fails to load, an error message is printed, and the function returns nil.
---
--- @param cb function A function to be executed with the loaded module as an argument.
--- @param ... string The names of the modules to load.
M.load_mods = function(cb, ...)
	local modules = { ... }
	for i, name in ipairs(modules) do
		local status_ok, module = pcall(require, name)
		if status_ok then
			modules[i] = module
		else
			require("utils.notify").error("Module " .. name .. " not found")
			return
		end
	end
	return cb(unpack(modules))
end

--- Close a buffer matching the specified filetypes or buftypes.
---
--- @param bufnr number The buffer number to close.
--- @param matches string|table The filetypes or buffer types to close.
--- @param condition_name string|nil Can be "filetype" or "buftype" (default: "filetype").
M.close_buffer_matching = function(bufnr, matches, condition_name)
	vim.schedule(function()
		local condition = api.nvim_get_option_value(condition_name or "filetype", { buf = bufnr })
		if type(matches) == "string" and condition == matches then
			api.nvim_buf_delete(bufnr, { force = true })
		elseif type(matches) == "table" then
			for _, match in ipairs(matches) do
				if type(match) == "string" and condition == match then
					api.nvim_buf_delete(bufnr, { force = true })
					return
				end
			end
		end
	end)
end

--- Close all buffers matching the specified filetypes or buffer types.
---
--- @param matches string|table The filetypes or buffer types to close.
--- @param condition_name string Can be "filetype" or "buftype".
M.close_buffers_matching = function(matches, condition_name)
	for _, buf in ipairs(api.nvim_list_bufs()) do
		if api.nvim_buf_is_valid(buf) then M.close_buffer_matching(buf, matches, condition_name) end
	end
end

--- Fast close all buffers matching the specified filetypes or buffer types.
---
--- @param matches string|table The filetypes or buffer types to close.
--- @param condition_name string Can be "filetype" or "buftype".
M.close_buffers_matching_in_visible_windows = function(matches, condition_name)
	local wins = api.nvim_list_wins()
	for _, win in ipairs(wins) do
		M.close_buffer_matching(api.nvim_win_get_buf(win), matches, condition_name)
	end
end

--- Close buffers specified by buffer numbers or filetypes/buftypes.
---
--- @param matches number|table The buffer numbers or table with filetypes/buftypes.
M.close_buffers = function(matches)
	if type(matches) == "number" and api.nvim_buf_is_valid(matches) then
		vim.schedule(function() api.nvim_buf_delete(matches, { force = true }) end)
	elseif type(matches) == "table" then
		for _, buf in ipairs(matches) do
			if type(buf) == "number" and api.nvim_buf_is_valid(buf) then
				vim.schedule(function() api.nvim_buf_delete(buf, { force = true }) end)
			end
		end
		for _, buf in ipairs(api.nvim_list_bufs()) do
			if api.nvim_buf_is_valid(buf) then
				M.close_buffer_matching(buf, matches, "filetype")
				M.close_buffer_matching(buf, matches, "buftype")
			end
		end
	end
end

return setmetatable(M, {
	__index = function(_, key) return require("utils." .. key) end,
})
