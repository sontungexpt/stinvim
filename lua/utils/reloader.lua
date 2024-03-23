local M = {}

M.hot_reload = function(quiet)
	-- Reload options, mappings
	local core_modules = {
		"core.command",
		"core.option",
		"core.nvimmap",
		"core.autocmd",
		"core.plugmap",
	}

	local failed_modules = {}
	for _, module in ipairs(core_modules) do
		package.loaded[module] = nil
		local status_ok, m = pcall(require, module)
		if not status_ok then
			table.insert(failed_modules, m)
		else
			if module == "core.plugmap" then
				for _, func in pairs(m) do
					if type(func) == "function" then func() end
				end
			end
		end
	end

	vim.api.nvim_exec_autocmds("ColorScheme", {})

	if not quiet then -- if not quiet, then notify of result.
		if #failed_modules == 0 then
			require("utils.notify").info("Reloaded options and nvimmap successfully")
		else
			require("utils.notify").error(
				"Error while reloading core modules: " .. table.concat(failed_modules, "\n")
			)
		end
	end
end

return M
