local M = {}

---
--- Creates a shallow clone of a table.
--- Copies all key-value pairs from the input table `tbl` to a new table.
--- If `tbl` contains nested tables, they are shallow cloned recursively.
--- @param tbl table The table to clone.
--- @return table A new table containing shallow copies of all key-value pairs from `tbl`.
function M.clone(tbl)
	local clone_tbl = {}
	if type(tbl) == "table" then
		for k, v in pairs(tbl) do
			clone_tbl[k] = M.clone(v)
		end
	else
		clone_tbl = tbl -- des[k] = v
	end
	return clone_tbl
end

---
--- Creates a deep clone of a table.
--- Copies all key-value pairs from the input table `tbl` to a new table.
--- If `tbl` contains nested tables, they are deep cloned recursively.
--- Also copies the metatable of `tbl` to the cloned table, if it exists.
--- @param tbl table The table to deep clone.
--- @return table A new table containing deep copies of all key-value pairs from `tbl`.
function M.deep_clone(tbl)
	local clone_tbl = {}
	if type(tbl) == "table" then
		local mt = getmetatable(tbl)
		if mt then
			local new_mt = M.clone(mt)
			setmetatable(clone_tbl, new_mt)
		end
		for k, v in pairs(tbl) do
			clone_tbl[k] = M.clone(v)
		end
	else
		clone_tbl = tbl -- des[k] = v
	end
	return clone_tbl
end

---
--- Merges two tables recursively, copying key-value pairs from `t2` into `t1`.
--- If both `t1` and `t2` have tables as values for the same key, they are merged recursively.
--- If `force` is `true`, `t1` is overwritten with `t2` even if `t1` is not `nil`.
--- @param t1 table The destination table to merge into.
--- @param t2 table The source table to merge from.
--- @param force boolean Optional. If `true`, overwrites `t1` with `t2` even if `t1` is not `nil`.
--- @return table The merged table `t1`.
M.merge = function(t1, t2, force)
	if type(t1) == "table" then
		for k, v in pairs(t2) do
			t1[k] = M.merge(t1[k], v, force)
		end
	elseif force or t1 == nil then
		t1 = t2
	end
	return t1
end

---
--- Deep merges two tables recursively, copying key-value pairs from `t2` into `t1`.
--- If both `t1` and `t2` have tables as values for the same key, they are deep merged recursively.
--- If `force` is `true`, `t1` is overwritten with `t2` even if `t1` is not `nil`.
--- Preserves metatables from both `t1` and `t2` during the merge.
--- @param t1 table The destination table to merge into.
--- @param t2 table The source table to merge from.
--- @param force boolean Optional. If `true`, overwrites `t1` with `t2` even if `t1` is not `nil`.
--- @return table The merged table `t1`.
M.deep_merge = function(t1, t2, force)
	if type(t1) == "table" then
		local mt2 = getmetatable(t2)
		if mt2 then
			local mt1 = getmetatable(t1)
			if mt1 then
				setmetatable(t1, M.merge(M.clone(mt1), mt2, force))
			else
				setmetatable(t1, mt2)
			end
		end

		for k, v in pairs(t2) do
			t1[k] = M.merge(t1[k], v, force)
		end
	elseif force or t1 == nil then
		t1 = t2
	end
	return t1
end

---
--- Shallowly extends a table by copying key-value pairs from `tb2` into a clone of `tb1`.
--- Uses shallow merge, which means that nested tables are not merged but overwritten.
--- If `force` is `true`, values from `tb2` will overwrite existing values in the clone of `tb1`.
--- @param tb1 table The base table to clone and extend.
--- @param tb2 table The table with values to copy into the clone of `tb1`.
--- @param force boolean Optional. If `true`, values from `tb2` overwrite existing values in the clone of `tb1`.
--- @return table A new table that is a shallowly extended clone of `tb1`.
function M.extend(tb1, tb2, force)
	local newtbl1 = M.clone(tb1)
	return M.merge(newtbl1, tb2, force)
end

---
--- Deeply extends a table by copying key-value pairs from `tb2` into a deep clone of `tb1`.
--- Uses deep merge, which means that nested tables are recursively merged.
--- Preserves metatables from both `tb1` and `tb2` during the merge.
--- If `force` is `true`, values from `tb2` will overwrite existing values in the deep clone of `tb1`.
--- @param tb1 table The base table to deep clone and extend.
--- @param tb2 table The table with values to copy into the deep clone of `tb1`.
--- @param force boolean Optional. If `true`, values from `tb2` overwrite existing values in the deep clone of `tb1`.
--- @return table A new table that is a deeply extended clone of `tb1`.
function M.deep_extend(tb1, tb2, force)
	local newtbl1 = M.deep_clone(tb1)
	return M.deep_merge(newtbl1, tb2, force)
end

--- Extends multiple tables by copying key-value pairs from all provided tables into a shallow clone of the first table.
--- If `force` is `true`, values from subsequent tables will overwrite existing values in the clone of the first table.
--- @param force boolean If `true`, values from subsequent tables overwrite existing values in the deep clone of the first table.
--- @param ... table The tables to be deep merged.
--- @return table A new table that is a deeply extended clone of the first table.
function M.extend_multitables(force, ...)
	local tables = { ... }
	local len = #tables
	if len > 1 then
		local result = M.clone(tables[1])
		for i = 2, len do
			result = M.merge(result, tables[i], force)
		end
		return result
	end
	return len > 0 and M.clone(tables[1]) or {}
end

---
--- Deeply extends multiple tables by copying key-value pairs from all provided tables into a deep clone of the first table.
--- Uses deep merge, which means that nested tables are recursively merged.
--- Preserves metatables from all tables during the merge.
--- If `force` is `true`, values from subsequent tables will overwrite existing values in the deep clone of the first table.
--- @param force boolean If `true`, values from subsequent tables overwrite existing values in the deep clone of the first table.
--- @param ... table The tables to be deep merged.
--- @return table A new table that is a deeply extended clone of the first table.
function M.deep_extend_multitables(force, ...)
	local tables = { ... }
	local len = #tables
	if len > 1 then
		local result = M.deep_clone(tables[1])
		for i = 2, len do
			result = M.deep_merge(result, tables[i], force)
		end
		return result
	end
	return len > 0 and M.deep_clone(tables[1]) or {}
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
