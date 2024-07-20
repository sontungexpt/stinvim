local M = {
	enabled = false,
}

M.entry = function()
	local id
	id = vim.api.nvim_create_autocmd("User", {
		desc = "Auto enable showmode if the window is small",
		pattern = "LazyLoad",
		callback = function(args)
			if args.data == "lualine.nvim" then
				vim.api.nvim_del_autocmd(id)
				if vim.o.columns > 70 then
					vim.opt.showmode = false
				else
					vim.opt.showmode = true
				end
			end
		end,
	})
end

return M
