local M = {
	enabled = true,
}

local is_authenticated = function()
	return vim.fn.filereadable(vim.fn.expand("$HOME") .. "/.codeium/config.json") == 1
end

M.entry = function()
	local id
	id = vim.api.nvim_create_autocmd("User", {
		pattern = "LazyLoad",
		desc = "Automatic auth for codeium",
		callback = function(args)
			if args.data == "codeium.vim" then
				vim.api.nvim_del_autocmd(id)
				vim.schedule(function()
					if not is_authenticated() then vim.api.nvim_command("Codeium Auth") end
				end)
			end
		end,
	})
end

return M
