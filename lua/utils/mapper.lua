local set_keymap, deep_extend = vim.keymap.set, vim.tbl_deep_extend

local M = {}

--- Options for key mappings.
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
--- @param opts table|number|nil: Options to be applied in vim.keymap.set (default: 1)
--- @param extend_opts table|nil: Extension or overriding of opts if opts is a number.
--- @see vim.keymap.set.Opts
M.map = function(mode, key, map_to, opts, extend_opts)
	if type(opts) == "table" then
		set_keymap(mode, key, map_to, deep_extend("force", OPTIONS[1], opts))
	elseif type(extend_opts) == "table" then
		set_keymap(mode, key, map_to, deep_extend("force", OPTIONS[opts] or OPTIONS[1], extend_opts))
	else
		set_keymap(mode, key, map_to, OPTIONS[opts] or OPTIONS[1])
	end
end

return M
