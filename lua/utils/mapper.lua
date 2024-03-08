local set_keymap = vim.keymap.set
local M = {}

---@tparam table|string mode : Table mode used for applying the key map if only one mode you can use string
---@tparam string key : The key you wish to map.
---@tparam function|string map_to : The key or function to be executed by the keymap.
---@tparam table|number opts : Options to be applied in vim.keymap.set.
---@tparam table extend_opts: Extension or overriding of opts if opts is a number.
--- Opts number: (default 1)
--- 1: { noremap = true, silent = true, nowait = true },
--- 2: { noremap = false, silent = true },
--- 3: { noremap = true, silent = false },
--- 4: { noremap = false, silent = false },
--- 5: { noremap = true, silent = true, expr = true, replace_keycodes = true },
--- 6: { noremap = true, silent = true, nowait = false },
--- 7: { noremap = true, silent = true, expr = true, replace_keycodes = true, nowait = true },
M.map = function(mode, key, map_to, opts, extend_opts)
	local opt_map = {
		{ noremap = true, silent = true, nowait = true },
		{ noremap = false, silent = true },
		{ noremap = true, silent = false },
		{ noremap = false, silent = false },
		{ noremap = true, silent = true, expr = true, replace_keycodes = true },
		{ noremap = true, silent = true, nowait = false },
		{ noremap = true, silent = true, expr = true, replace_keycodes = true, nowait = true },
	}

	if type(opts) == "table" then
		set_keymap(mode, key, map_to, vim.tbl_deep_extend("force", opt_map[1], opts))
	elseif type(extend_opts) == "table" then
		set_keymap(mode, key, map_to, vim.tbl_deep_extend("force", opt_map[opts] or opt_map[1], extend_opts))
	else
		set_keymap(mode, key, map_to, opt_map[opts] or opt_map[1])
	end
end

return M
