local levels, notify, schedule = vim.log.levels, vim.notify, vim.schedule

local M = {}

M.info = function(msg, opts)
	schedule(function() notify(msg, levels.INFO, opts or { title = "Information" }) end)
end

M.warn = function(msg, opts)
	schedule(function() notify(msg, levels.WARN, opts or { title = "Warning" }) end)
end

M.error = function(msg, opts)
	schedule(function() notify(msg, levels.ERROR, opts or { title = "Error" }) end)
end

M.debug = function(msg, opts)
	schedule(function() notify(msg, levels.DEBUG, opts or { title = "Debug" }) end)
end

M.trace = function(msg, opts)
	schedule(function() notify(msg, levels.TRACE, opts or { title = "Trace" }) end)
end

M.off = function(msg, opts)
	schedule(function() notify(msg, levels.OFF, opts or { title = "Off" }) end)
end

M.info_after = function(msg, wait, opts)
	vim.defer_fn(function() notify(msg, levels.INFO, opts or { title = "Information" }) end, wait)
end

M.warn_after = function(msg, wait, opts)
	vim.defer_fn(function() notify(msg, levels.WARN, opts or { title = "Warning" }) end, wait)
end

M.error_after = function(msg, wait, opts)
	vim.defer_fn(function() notify(msg, levels.ERROR, opts or { title = "Error" }) end, wait)
end

M.debug_after = function(msg, wait, opts)
	vim.defer_fn(function() notify(msg, levels.DEBUG, opts or { title = "Debug" }) end, wait)
end

M.trace_after = function(msg, wait, opts)
	vim.defer_fn(function() notify(msg, levels.TRACE, opts or { title = "Trace" }) end, wait)
end

M.off_after = function(msg, wait, opts)
	vim.defer_fn(function() notify(msg, levels.OFF, opts or { title = "Off" }) end, wait)
end

return M
