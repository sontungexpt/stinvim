local set_keymap = vim.keymap.set

local M = {}

--- @class MapperOpts
--- @see vim.keymap.set.Opts
local OPTIONS = {
	{ noremap = true, silent = true, nowait = true },
	{ noremap = false, silent = true },
	{ noremap = true, silent = false },
	{ noremap = false, silent = false },
	{ noremap = true, silent = true, nowait = false },
	{ noremap = true, silent = true, expr = true },
	{ noremap = true, silent = true, expr = true, nowait = true },
}

--- Set a key mapping in Vim.
--- @param mode table|string: The mode used for applying the key map.
--- @param key string: The key you wish to map.
--- @param map_to function|string: The key or function to be executed by the key map.
--- @param opts ? table|number|string: If opts is a string, it will be used as the description, else if number it will be used as the default keymap options provided by stinvim else if opts is a table it will be used as vim.keymap.set.Opts
--- @param extend_opts ? table|string: Extension or overriding of opts if opts is a number, If opts is a string, it will be used as the description,
--- @see MapperOpts
--- opts: Can be a number or a `vim.keymap.set.Opts`
M.map = function(mode, key, map_to, opts, extend_opts)
	local opts_type = type(opts)
	local options
	if opts_type == "string" then
		options = OPTIONS[1]
		options.desc = opts
	else
		options = opts_type == "table" and require("utils.tbl").extend(OPTIONS[1], opts, true)
			or OPTIONS[opts or 1]
			or OPTIONS[1]
		if extend_opts then
			local extend_opts_type = type(extend_opts)
			if extend_opts_type == "string" then
				options.desc = extend_opts
			elseif extend_opts_type == "table" then
				options = require("utils.tbl").extend(options, extend_opts, true)
			end
		end
	end
	set_keymap(mode, key, map_to, options)
	options.desc = nil
end

return M
