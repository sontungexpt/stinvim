local M = {}

---
-- default opts = 1
-- opts = 1 for noremap and silent
-- opts = 2 for not noremap and silent
-- opts = 3 for noremap and not silent
-- opts = 4 for not noremap and not silent
-- opts = 5 for expr and noremap and silent
-- opts = 6 for noremap and silent and nowait
-- opts = 7 for noremap and silent and nowait and expr
M.map = function(mode, key, map_to, opts)
	local opts1 = { noremap = true, silent = true }
	opts = opts or 1
	if type(opts) == "table" then
		opts = vim.tbl_deep_extend("force", opts1, opts)
		vim.keymap.set(mode, key, map_to, opts)
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
		opts = { noremap = true, silent = true, nowait = true }
	elseif opts == 7 then
		opts = { expr = true, replace_keycodes = true, noremap = true, silent = true, nowait = true }
	else
		opts = opts1
	end
	vim.keymap.set(mode, key, map_to, opts)
end

return M
