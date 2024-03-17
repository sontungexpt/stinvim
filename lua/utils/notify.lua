local M = {}

local levels, notify, schedule = vim.log.levels, vim.notify, vim.schedule

M.info = function(msg, opts)
	schedule(function()
		vim.cmd("redraw")
		notify(msg, levels.INFO, opts or { title = "Information" })
	end)
end

M.warn = function(msg, opts)
	schedule(function()
		vim.cmd("redraw")
		notify(msg, levels.WARN, opts or { title = "Warning" })
	end)
end

M.error = function(msg, opts)
	schedule(function()
		vim.cmd("redraw")
		notify(msg, levels.ERROR, opts or { title = "Error" })
	end)
end

M.debug = function(msg, opts)
	schedule(function()
		vim.cmd("redraw")
		notify(msg, levels.DEBUG, opts or { title = "Debug" })
	end)
end

M.trace = function(msg, opts)
	schedule(function()
		vim.cmd("redraw")
		notify(msg, levels.TRACE, opts or { title = "Trace" })
	end)
end

M.off = function(msg, opts)
	schedule(function()
		vim.cmd("redraw")
		notify(msg, levels.OFF, opts or { title = "Off" })
	end)
end

return M
