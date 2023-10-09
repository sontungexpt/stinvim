local M = {}

M.create_autocmds = function()
	vim.api.nvim_create_autocmd("User", {
		pattern = "GitConflictDetected",
		callback = function()
			vim.schedule(function() vim.notify("Conflict detected in " .. vim.fn.expand("<afile>")) end)
		end,
	})
end

return M
