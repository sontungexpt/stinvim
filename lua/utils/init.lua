local api, fn, pcall = vim.api, vim.fn, pcall

local M = {}

--- Get the root directory of the project.
---
--- @return string: The root directory of the project
M.find_root = function()
	return vim.fs.find(vim.g.stinvim_root_markers or {
		".git",
		"package.json", -- npm
		"Cargo.toml", -- rust
		"build.zig", -- zig
		"stylua.toml", -- lua
		"lazy-lock.json", -- nvim config
		"gradlew", -- java
		"mvnw", -- java
	}, { upward = true })[1]
end

--- Check if two tables contain the same items, regardless of order and duplicates.
---
--- @param table1 table The first table to compare
--- @param table2 table The second table to compare
--- @return boolean: Whether the two tables are contain the same items
M.is_same_set = function(table1, table2) -- O(n)
	local tbl1_hash = {} -- to check that all elements are in table2
	local tbl2_hash = {} -- to check for duplicates in table2

	for _, value in ipairs(table1) do
		tbl1_hash[value] = true
	end

	for _, value in ipairs(table2) do
		if not tbl1_hash[value] and not tbl2_hash[value] then return false end
		tbl1_hash[value] = nil
		tbl2_hash[value] = true
	end

	return next(tbl1_hash) == nil -- check if all elements in table1 are in table2
end

--- Check if two tables contain the same items, regardless of order.
---
--- @param table1 table The first table to compare
--- @param table2 table The second table to compare
--- @return boolean: Whether the two tables are contain the same items
M.is_same_array = function(table1, table2) -- O(n)
	if #table1 ~= #table2 then return false end

	local counts = {}

	for _, value in ipairs(table1) do
		counts[value] = (counts[value] or 0) + 1
	end

	for _, value in ipairs(table2) do
		local count = counts[value]
		if not count or count == 0 then return false end
		counts[value] = count - 1
	end

	return true
end

--- Finds the items in the source table that are not present in the target table.
---
--- @param source table The source table to find unique items that are not in target table
--- @param target table The target table to compare with the source table
--- @return table The unique items in source table that are not in target table
M.find_unique_array_items = function(source, target)
	if next(source) == nil then return target end

	local founds = {}
	local unique_items = {}

	for _, value in ipairs(target) do
		founds[value] = true
	end

	local index = 0
	for _, value in ipairs(source) do
		if not founds[value] then
			index = index + 1
			unique_items[index] = value
		end
	end

	return unique_items
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
--- @param module_name string The name of the module to load.
--- @param cb function A function to be executed with the loaded module as an argument.
M.load_and_exec = function(module_name, cb)
	local status_ok, module = pcall(require, module_name)
	if status_ok then
		cb(module)
	else
		require("utils.notify").error("Module " .. module_name .. " not found")
	end
end

--- Close buffer if it matches the specified condition.
---
--- @param bufnr number The buffer number.
--- @param matches string|table The filetypes or buftypes to match.
--- @param condition_name string Can be "filetype" or "buftype" (default: "filetype")
M.close_buffer_matching = function(bufnr, matches, condition_name)
	if not api.nvim_buf_is_valid(bufnr) then return end
	local buffer_condition = api.nvim_buf_get_option(bufnr, condition_name or "filetype")
	if type(matches) == "string" and buffer_condition == matches then
		api.nvim_buf_delete(bufnr, { force = true })
	elseif type(matches) == "table" then
		for _, match in ipairs(matches) do
			if buffer_condition == match then
				api.nvim_buf_delete(bufnr, { force = true })
				break
			end
		end
	end
end

--- Close all buffers matching the specified filetypes or buffer types.
---
--- @param matches string|table The filetypes or buffer types to close.
--- @param condition_name string Can be "filetype" or "buftype".
M.close_buffers_matching = function(matches, condition_name)
	vim.schedule(function()
		for _, buf in ipairs(api.nvim_list_bufs()) do
			M.close_buffer_matching(buf, matches, condition_name)
		end
	end)
end

--- Close buffers specified by buffer numbers or filetypes/buftypes.
---
--- @param matches number|table The buffer numbers or table with filetypes/buftypes.
M.close_buffers = function(matches)
	vim.schedule(function()
		if type(matches) == "number" and api.nvim_buf_is_valid(matches) then
			api.nvim_buf_delete(matches, { force = true })
		elseif type(matches) == "table" then
			for _, buf in ipairs(matches) do
				if type(buf) == "number" and api.nvim_buf_is_valid(buf) then
					api.nvim_buf_delete(buf, { force = true })
				end
			end
			for _, buf in ipairs(api.nvim_list_bufs()) do
				M.close_buffer_matching(buf, matches, "filetype")
				M.close_buffer_matching(buf, matches, "buftype")
			end
		end
	end)
end

return M
