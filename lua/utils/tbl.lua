local M = {}

M.merge_tbl = function(default_opts, user_opts, force)
	local default_options_type = type(default_opts)

	if default_options_type == type(user_opts) then
		if default_options_type == "table" and default_opts[1] == nil then
			for k, v in pairs(user_opts) do
				default_opts[k] = M.merge_tbl(default_opts[k], v)
			end
		elseif force then
			default_opts = user_opts
		elseif default_opts == nil then
			default_opts = user_opts
		end
	elseif default_opts == nil then
		default_opts = user_opts
	end
	return default_opts
end

function M.clone(tbl)
	local new_tbl = {}
	for k, v in pairs(tbl) do
		if type(v) == "table" then
			new_tbl[k] = M.clone(v)
		else
			new_tbl[k] = v
		end
	end
	return new_tbl
end

--- Check if two tables contain the same items, regardless of order and duplicates.
---
--- @param table1 table The first table to compare
--- @param table2 table The second table to compare
--- @return boolean: Whether the two tables are contain the same items
M.same_set = function(table1, table2) -- O(n)
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
M.same_array = function(table1, table2) -- O(n)
	local len1 = #table1
	local len2 = #table2
	if len1 ~= len2 then return false end

	local counts = {}

	for i = 1, len1, 1 do
		local v = table1[i]
		counts[v] = (counts[v] or 0) + 1
	end

	for i = 1, len2, 1 do
		local v = table2[i]
		local count = counts[v]
		if not count or count == 0 then return false end
		counts[v] = count - 1
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

return M
