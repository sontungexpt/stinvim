local M = {}

M.to_array = function(json_str)
	local array = {}

	for value in json_str:gmatch('"([^"]+)"') do
		table.insert(array, value)
	end

	return array
end

return M
