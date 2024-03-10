local api = vim.api
local fn = vim.fn

local M = {}

--- Get the root directory of the project
--- @return string: The root directory of the project
M.find_root = function()
	return vim.fs.find(vim.g.stinvim_root_markers or {
		".git",
		"package.json", -- npm
		"Cargo.toml", -- rust
		"stylua.toml", -- lua
		"lazy-lock.json", -- nvim config
		"gradlew", -- java
		"mvnw", -- java
	}, { upward = true })[1]
end

--- Check if two tables contain the same items, regardless of order and duplicates
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

	return next(tbl1_hash) == nil -- if tbl1_hash is empty, then all elements are in table2
end

--- Check if two tables contain the same items, regardless of order
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

--- @param source table The source table to find unique items
--- @param target table The target table to compare with source table
--- @return table The unique items in source table that are not in target table
M.find_unique_items = function(source, target)
	if #target == 0 then return source end

	local not_exists = {}
	local counts = {}

	for _, value in ipairs(target) do
		counts[value] = true
	end

	for _, value in ipairs(source) do
		if not counts[value] then table.insert(not_exists, value) end
	end

	return not_exists
end

--- Execute a command by calling `vim.api.nvim_command` function
--- @tparam string command: The command to execute
--- @tparam table msg: The message to print on success or error
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

M.is_plug_installed = function(plugin_name, custom_dir)
	custom_dir = custom_dir or "/lazy/"
	if not vim.startswith(custom_dir, "/") then custom_dir = "/" .. custom_dir end
	if not vim.endswith(custom_dir, "/") then custom_dir = custom_dir .. "/" end

	return fn.isdirectory(fn.stdpath("data") .. custom_dir .. plugin_name) == 1
end

M.load_and_exec = function(module_name, cb)
	local status_ok, module = pcall(require, module_name)
	if status_ok then
		cb(module)
	else
		require("utils.notify").error("Module " .. module_name .. " not found")
	end
end

return M
