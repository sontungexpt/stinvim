local set_keymap = vim.keymap.set
local M = {}

---@tparam table|string mode : Table mode used for applying the key map if only one mode you can use string
---@tparam string key : The key you wish to map.
---@tparam function|string map_to : The key or function to be executed by the keymap.
---@tparam table|number opts : Options to be applied in vim.keymap.set.
--- - Default opts = 1.
--- - opts = 1 for noremap and silent and nowait.
--- - opts = 2 for not noremap and silent.
--- - opts = 3 for noremap and not silent.
--- - opts = 4 for not noremap and not silent.
--- - opts = 5 for expr and noremap and silent.
--- - opts = 6 for noremap and silent and wait.
--- - opts = 7 for noremap and silent and nowait and expr.
---@tparam table extend_opts: Extension or overriding of opts if opts is a number.
M.map = function(mode, key, map_to, opts, extend_opts)
	local opts1 = { noremap = true, silent = true, nowait = true }
	opts = opts or 1
	if type(opts) == "table" then
		opts = vim.tbl_deep_extend("force", opts1, opts)
		set_keymap(mode, key, map_to, opts)
		return
	end

	if opts == 1 then
		opts = opts1
	elseif opts == 2 then
		opts = { noremap = false, silent = true }
	elseif opts == 3 then
		opts = { noremap = true, silent = false }
	elseif opts == 4 then
		opts = { noremap = false, silent = false }
	elseif opts == 5 then
		opts = { expr = true, replace_keycodes = true, noremap = true, silent = true }
	elseif opts == 6 then
		opts = { noremap = true, silent = true, nowait = false }
	elseif opts == 7 then
		opts = { expr = true, replace_keycodes = true, noremap = true, silent = true, nowait = true }
	else
		opts = opts1
	end

	if type(extend_opts) == "table" then opts = vim.tbl_deep_extend("force", opts, extend_opts) end

	set_keymap(mode, key, map_to, opts)
end

return M
