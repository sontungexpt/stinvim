local options = {
	size = function(term) ---@type number|function
		if term.direction == "horizontal" then
			return 15
		elseif term.direction == "vertical" then
			return vim.o.columns * 0.4
		end
	end,
	open_mapping = [[<C-t>]],
	on_create = function(term)
		local map = require("utils.mapper").map
		local api = vim.api

		local term_id = term.id
		local bufnr = term.bufnr

		local map1 = function(mode, key, map_to, expr) map(mode, key, map_to, { buffer = bufnr, expr = expr }) end

		local new_term_id = term_id
		local pressed_time = 0

		map1({ "n", "t" }, "<C-t>", function()
			if new_term_id ~= term_id and (vim.uv or vim.loop).now() - pressed_time < 1500 then
				vim.defer_fn(function()
					api.nvim_command(new_term_id .. "ToggleTerm")
					new_term_id = term_id
				end, 20)
				api.nvim_input("<BS>")
			else
				new_term_id = term_id
				api.nvim_command(term_id .. "ToggleTerm")
			end
		end)

		for i = 1, 9, 1 do
			local istr = tostring(i)
			map1({ "n", "t" }, istr, function()
				pressed_time = (vim.uv or vim.loop).now()
				new_term_id = i
				return istr
			end, true)
		end
	end,
	on_open = function(term)
		require("utils.notify").info("Terminal " .. term.id .. " opened")
		vim.api.nvim_command("startinsert")
	end,
	on_close = function(term) vim.api.nvim_command("stopinsert") end,
	hide_numbers = true,
	autochdir = true,
	shade_filetypes = {},
	shade_terminals = false,
	-- the degree by which to darken to terminal colour,
	-- default: 1 for dark backgrounds, 3 for light
	shading_factor = 1,
	start_in_insert = true,
	insert_mappings = true, -- whether or not the open mapping applies in insert mode
	persist_size = true,
	direction = "horizontal", -- | 'horizontal' | 'horizontal' | 'tab' | 'float',,
	close_on_exit = true, -- close the terminal window when the process exits
	shell = vim.o.shell, -- change the default shell
	auto_scroll = true,
	float_opts = {
		border = "single", -- single/double/shadow/curved
		width = math.floor(0.9 * vim.o.columns),
		height = math.floor(0.85 * vim.o.lines),
		winblend = 3,
	},
	winbar = {
		enabled = false,
		name_formatter = function(term) return "" end,
	},
}

return options
