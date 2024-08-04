local fn = vim.fn
local api = vim.api

local M = {}

local winid = function(direction) return direction and fn.win_getid(fn.winnr(direction)) or api.nvim_get_current_win() end

---Increase the width of the current window flexibly
---
---@param step uinteger The step of increasing
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
			local idx = 1
			local last_left_id = -1
			local left_id = winid("h")
			local widths = {
				{ id = left_id, width = api.nvim_win_get_width(left_id) },
			}

			while widths[idx].width <= vim.o.winminwidth do
				if last_left_id == left_id then
					api.nvim_win_set_width(0, win_width + step)
					break
				else
					last_left_id = left_id
					idx = idx + 1
					left_id = winid(idx .. "h")
					widths[idx] = { id = left_id, width = api.nvim_win_get_width(left_id) }
				end
			end

			for i = idx, 1, -1 do
				local adjust_width = step * idx
				api.nvim_win_set_width(widths[i].id, widths[i].width - adjust_width)
				if i > 1 then widths[i - 1].width = widths[i - 1].width + adjust_width end
			end
		end
	end)
end

---Decrease the width of the current window flexibly
---@param step uinteger The step of decreasing
M.decrease_current_win_width = function(step)
	vim.schedule(function()
		local win_width = api.nvim_win_get_width(0)
		local winnr = fn.winnr()
		if winnr == fn.winnr("l") then
			api.nvim_win_set_width(0, win_width + step)
		elseif winnr == fn.winnr("h") then
			api.nvim_win_set_width(0, win_width - step)
		elseif api.nvim_win_get_position(0)[2] + win_width / 2 > vim.o.columns / 2 then
			if win_width > vim.o.winminwidth then api.nvim_win_set_width(0, win_width - step) end
		else
			local left_win_id = winid("h")
			api.nvim_win_set_width(left_win_id, api.nvim_win_get_width(left_win_id) + step)
		end
	end)
end

---Decrease the height of the current window flexibly
---@param step uinteger The step of decreasing
M.decrease_current_win_height = function(step)
	vim.schedule(function()
		local win_height = api.nvim_win_get_height(0)
		local winnr = fn.winnr()
		if winnr == fn.winnr("j") then
			api.nvim_win_set_height(0, win_height + step)
		elseif winnr == fn.winnr("k") then
			api.nvim_win_set_height(0, win_height - step)
		elseif
			api.nvim_win_get_position(0)[1] + win_height / 2
			> (
					vim.o.lines
					- vim.o.cmdheight
					- (vim.o.laststatus ~= 0 and 1 or 0)
					- (vim.o.showtabline ~= 0 and #api.nvim_list_tabpages() > 1 and 1 or 0)
				)
				/ 2
		then
			if win_height > vim.o.winminheight then api.nvim_win_set_height(0, win_height - step) end
		else
			local left_win_id = winid("k")
			api.nvim_win_set_height(left_win_id, api.nvim_win_get_height(left_win_id) + step)
		end
	end)
end

---Increase the height of the current window flexibly
---@param step uinteger The step of increasing
M.increase_current_win_height = function(step)
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
			local idx = 1
			local last_top_id = -1
			local top_id = winid("k")
			local heights = {
				{ id = top_id, height = api.nvim_win_get_height(top_id) },
			}
			while heights[idx].height <= vim.o.winminheight do
				if last_top_id == top_id then
					api.nvim_win_set_height(0, win_height + step)
					break
				else
					last_top_id = top_id
					idx = idx + 1
					top_id = winid(idx .. "k")
					heights[idx] = { id = top_id, height = api.nvim_win_get_height(top_id) }
				end
			end
			for i = idx, 1, -1 do
				local adjust_height = step * idx
				api.nvim_win_set_height(heights[i].id, heights[i].height - adjust_height)
				if i > 1 then heights[i - 1].height = heights[i - 1].height + adjust_height end
			end
		end
	end)
end

return M
