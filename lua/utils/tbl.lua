local M = {}

local type = type
local next = next
local getmetatable = getmetatable
local setmetatable = setmetatable

-- ---------------------------------------------------------------------------
-- Clone
-- ---------------------------------------------------------------------------

--- Create a shallow copy of a table.
--- Nested tables and keys retain their original references.
--- @generic T: table
--- @param tbl T
--- @return T
function M.clone(tbl)
	if type(tbl) ~= "table" then
		return tbl
	end

	local result = {}
	for k, v in next, tbl do
		result[k] = v
	end

	return result
end

--- Create a deep copy of a table.
--- Handles cyclic references and preserves table metatables.
--- @generic T: table
--- @param tbl T
--- @return T
function M.deep_clone(tbl)
	if type(tbl) ~= "table" then
		return tbl
	end

	local seen = {}

	local function copy(source)
		local cached = seen[source]
		if cached then
			return cached
		end

		local result = {}
		seen[source] = result

		for k, v in next, source do
			result[copy(k)] = copy(v)
		end

		local mt = getmetatable(source)
		if type(mt) == "table" then
			setmetatable(result, copy(mt))
		end

		return result
	end

	return copy(tbl)
end

-- ---------------------------------------------------------------------------
-- Merge
-- ---------------------------------------------------------------------------

--- Recursively merge t2 into t1.
--- Mutates and returns t1.
--- @param t1 table Destination table
--- @param t2 table Source table
--- @param force? boolean Override existing non-table values
--- @return table
function M.merge(t1, t2, force)
	if type(t1) ~= "table" or type(t2) ~= "table" then
		if force or t1 == nil then
			return t2
		end
		return t1
	end

	for k, v in next, t2 do
		local current = t1[k]

		if type(current) == "table" and type(v) == "table" then
			M.merge(current, v, force)
		elseif force or current == nil then
			t1[k] = v
		end
	end

	return t1
end

--- Deep merge with metatable preservation.
--- Mutates and returns t1.
--- @param t1 table Destination table
--- @param t2 table Source table
--- @param force? boolean Override existing non-table values
--- @return table
function M.deep_merge(t1, t2, force)
	if type(t1) ~= "table" or type(t2) ~= "table" then
		if force or t1 == nil then
			return t2
		end
		return t1
	end

	local mt2 = getmetatable(t2)
	if type(mt2) == "table" then
		local mt1 = getmetatable(t1)

		if type(mt1) == "table" then
			M.merge(mt1, mt2, force)
		else
			setmetatable(t1, mt2)
		end
	end

	for k, v in next, t2 do
		local current = t1[k]

		if type(current) == "table" and type(v) == "table" then
			M.deep_merge(current, v, force)
		elseif force or current == nil then
			t1[k] = v
		end
	end

	return t1
end

-- ---------------------------------------------------------------------------
-- Extend
-- ---------------------------------------------------------------------------

--- Shallowly extend a table.
--- Values from tb2 overwrite existing values when force is true.
--- @param tb1 table Base table
--- @param tb2 table Extension table
--- @param force? boolean
--- @return table
function M.extend(tb1, tb2, force)
	local result = M.clone(tb1)

	if type(tb2) ~= "table" then
		return result
	end

	if force then
		for k, v in next, tb2 do
			result[k] = v
		end
	else
		for k, v in next, tb2 do
			if result[k] == nil then
				result[k] = v
			end
		end
	end

	return result
end

--- Deeply extend a table.
--- @param tb1 table Base table
--- @param tb2 table Extension table
--- @param force? boolean
--- @return table
function M.deep_extend(tb1, tb2, force)
	return M.deep_merge(M.deep_clone(tb1), tb2, force)
end

--- Extend multiple tables using recursive merge semantics.
--- @param force boolean
--- @param ... table
--- @return table
function M.extend_multitables(force, ...)
	local count = select("#", ...)
	if count == 0 then
		return {}
	end

	local result = M.clone(select(1, ...))

	for i = 2, count do
		M.merge(result, select(i, ...), force)
	end

	return result
end

--- Deeply extend multiple tables.
--- @param force boolean
--- @param ... table
--- @return table
function M.deep_extend_multitables(force, ...)
	local count = select("#", ...)
	if count == 0 then
		return {}
	end

	local result = M.deep_clone(select(1, ...))

	for i = 2, count do
		M.deep_merge(result, select(i, ...), force)
	end

	return result
end

-- ---------------------------------------------------------------------------
-- Array comparison
-- ---------------------------------------------------------------------------

--- Compare two arrays as sets.
--- Ignores order and duplicate elements.
--- @param table1 table
--- @param table2 table
--- @return boolean
function M.same_set(table1, table2)
	local set = {}

	for i = 1, #table1 do
		set[table1[i]] = true
	end

	for i = 1, #table2 do
		local value = table2[i]

		if not set[value] then
			return false
		end

		set[value] = nil
	end

	return next(set) == nil
end

--- Compare two arrays as multisets.
--- Ignores order but preserves duplicate counts.
--- @param table1 table
--- @param table2 table
--- @return boolean
function M.same_array(table1, table2)
	local len = #table1

	if len ~= #table2 then
		return false
	end

	local counts = {}

	for i = 1, len do
		local value = table1[i]
		counts[value] = (counts[value] or 0) + 1
	end

	for i = 1, len do
		local value = table2[i]
		local count = counts[value]

		if not count then
			return false
		end

		if count == 1 then
			counts[value] = nil
		else
			counts[value] = count - 1
		end
	end

	return next(counts) == nil
end

--- Find unique values in source that are absent from target.
--- Preserves source order.
--- @param source table
--- @param target table
--- @return table
function M.find_unique_array_items(source, target)
	local result = {}
	local found = {}

	for i = 1, #target do
		found[target[i]] = true
	end

	for i = 1, #source do
		local value = source[i]

		if not found[value] then
			found[value] = true
			result[#result + 1] = value
		end
	end

	return result
end

return M
