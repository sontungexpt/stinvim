local fn = vim.fn

local M = {}

M.is_terminal = function(terminal_name)
	local term = vim.env.TERM or ""
	return term:lower() == terminal_name
end

M.switch_language_engine = function(engine)
	local current_engine = fn.system("ibus engine"):gsub("%s+", "")
	if current_engine ~= engine then
		local engines = fn.system("ibus list-engine"):gsub("%s+", "")
		if engines:find(engine) then
			fn.system("ibus engine " .. engine)
		else
			require("utils.notify").error("Engine not found: " .. engine)
		end
	end
end
return M
