local fn = vim.fn
local api = vim.api

local M = {}

local winid = function(direction) return direction and fn.win_getid(fn.winnr(direction)) or api.nvim_get_current_win() end

M.increase_current_win_width = function(step)
	vim.schedule(function()
		local winnr = fn.winnr()
		local win_width = api.nvim_win_get_width(0)
		if winnr == fn.winnr("l") then
			api.nvim_win_set_width(0, win_width - step)
		elseif winnr == fn.winnr("h") then
			api.nvim_win_set_width(0, win_width + step)
		elseif api.nvim_win_get_position(0)[2] + win_width / 2 < vim.o.columns / 2 then
			api.nvim_win_set_width(0, win_width + step)
		else
			local left_win_id = winid("h")
			api.nvim_win_set_width(left_win_id, api.nvim_win_get_width(left_win_id) - step)
		end
	end)
end

M.decrease_current_win_width = function(step)
	vim.schedule(function()
		local win_width = api.nvim_win_get_width(0)
		local winnr = fn.winnr()
		if winnr == fn.winnr("l") then
			api.nvim_win_set_width(0, win_width + step)
		elseif winnr == fn.winnr("h") then
			api.nvim_win_set_width(0, win_width - step)
		elseif win_width > vim.o.winminwidth and api.nvim_win_get_position(0)[2] + win_width / 2 > vim.o.columns / 2 then
			api.nvim_win_set_width(0, win_width - step)
		else
			local left_win_id = winid("h")
			api.nvim_win_set_width(left_win_id, api.nvim_win_get_width(left_win_id) + step)
		end
	end)
end

M.decrease_current_win_height = function(step)
	vim.schedule(function()
		local win_height = api.nvim_win_get_height(0)
		local winnr = fn.winnr()
		if winnr == fn.winnr("j") then
			api.nvim_win_set_height(0, win_height + step)
		elseif winnr == fn.winnr("k") then
			api.nvim_win_set_height(0, win_height - step)
		elseif
			win_height > vim.o.winminheight
			and api.nvim_win_get_position(0)[1] + win_height / 2
				> (vim.o.lines - vim.o.cmdheight - (vim.o.laststatus ~= 0 and 1 or 0) - (vim.o.showtabline ~= 0 and #api.nvim_list_tabpages() > 1 and 1 or 0)) / 2
		then
			api.nvim_win_set_height(0, win_height - step)
		else
			local left_win_id = winid("k")
			api.nvim_win_set_height(left_win_id, api.nvim_win_get_height(left_win_id) + step)
		end
	end)
end

M.increase_win_height = function(step)
	vim.schedule(function()
		local winnr = fn.winnr()
		local win_height = api.nvim_win_get_height(0)
		if winnr == fn.winnr("j") then
			api.nvim_win_set_height(0, win_height - step)
		elseif winnr == fn.winnr("k") then
			api.nvim_win_set_height(0, win_height + step)
		elseif
			win_height > vim.o.winminheight
			and api.nvim_win_get_position(0)[1] + win_height / 2
				< (vim.o.lines - vim.o.cmdheight - (vim.o.laststatus ~= 0 and 1 or 0) - (vim.o.showtabline ~= 0 and #api.nvim_list_tabpages() > 1 and 1 or 0)) / 2
		then
			api.nvim_win_set_height(0, win_height + step)
		else
			local left_win_id = winid("k")
			api.nvim_win_set_height(left_win_id, api.nvim_win_get_height(left_win_id) - step)
		end
	end)
end

return M
