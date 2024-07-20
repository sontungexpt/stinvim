local M = {
	enabled = true,
}

M.entry = function()
	vim.api.nvim_create_autocmd("User", {
		pattern = "GitConflictDetected",
		callback = function() require("utils.notify").warn("Conflict detected in " .. vim.fn.expand("<afile>")) end,
	})
end

return M
