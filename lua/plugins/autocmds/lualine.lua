local M = {}

M.create_autocmds = function()
	vim.api.nvim_create_autocmd({ "VimEnter", "VimResized" }, {
		desc = "Enable the 'noshowmode' option when resizing the window width exceeds 70 if lualine is installed",
		callback = function()
			if not require("utils").is_plug_installed("lualine.nvim") then
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
