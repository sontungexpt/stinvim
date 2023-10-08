local M = {}

M.echo = function(str)
	vim.cmd("redraw")
	vim.api.nvim_echo({ { str, "Bold" } }, true, {})
end

M.shell_call = function(args)
	local output = vim.fn.system(args)

	assert(
		vim.v.shell_error == 0,
"External call failed with error code: " .. vim.v.shell_error .. "\n" .. output
	)
end

M.lazy = function(install_path)
	--------- lazy.nvim ---------------
	M.echo("  Installing lazy.nvim & plugins ...")
	local repo = "https://github.com/folke/lazy.nvim.git"
	M.shell_call { "git", "clone", "--filter=blob:none", "--branch=stable", repo, install_path }
	vim.opt.rtp:prepend(install_path)

	-- install plugins
	require("plugins")
	vim.api.nvim_buf_delete(0, { force = true }) -- close lazy window
end

return M
