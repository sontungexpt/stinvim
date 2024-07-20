local set_keymap, tbl_extend = vim.keymap.set, require("utils.tbl").extend

local M = {}

--- @class MapperOpts
--- @see vim.keymap.set.Opts
local OPTIONS = {
	{ noremap = true, silent = true, nowait = true },
	{ noremap = false, silent = true },
	{ noremap = true, silent = false },
	{ noremap = false, silent = false },
	{ noremap = true, silent = true, nowait = false },
	{ noremap = true, silent = true, expr = true, replace_keycodes = true },
	{ noremap = true, silent = true, expr = true, replace_keycodes = true, nowait = true },
}

--- Set a key mapping in Vim.
--- @param mode table|string: The mode used for applying the key map.
--- @param key string: The key you wish to map.
--- @param map_to function|string: The key or function to be executed by the key map.
--- @param opts ? vim.keymap.set.Opts|number: Options to be applied in vim.keymap.set (default: 1)
--- @param extend_opts ? vim.keymap.set.Opts: Extension or overriding of opts if opts is a number.
--- @see MapperOpts
--- opts: Can be a number or a `vim.keymap.set.Opts`
--- - `1`: `{ noremap = true, silent = true, nowait = true }`
--- - `2`: `{ noremap = false, silent = true }`
--- - `3`: `{ noremap = true, silent = false }`
--- - `4`: `{ noremap = false, silent = false }`
--- - `5`: `{ noremap = true, silent = true, nowait = false }`
--- - `6`: `{ noremap = true, silent = true, expr = true, replace_keycodes = true }`
--- - `7`: `{ noremap = true, silent = true, expr = true, replace_keycodes = true, nowait = true }`
M.map = function(mode, key, map_to, opts, extend_opts)
	if type(opts) == "table" then
		set_keymap(mode, key, map_to, tbl_extend(OPTIONS[1], opts, true))
	elseif type(extend_opts) == "table" then
		set_keymap(mode, key, map_to, tbl_extend(OPTIONS[opts] or OPTIONS[1], extend_opts, true))
	else
		set_keymap(mode, key, map_to, OPTIONS[opts] or OPTIONS[1])
	end
end

return M
