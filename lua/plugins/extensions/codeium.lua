local M = {
	enabled = true,
}

local is_authenticated = function() return vim.fn.isdirectory(vim.fn.expand("$HOME") .. "/.codeium") == 1 end

M.entry = function()
	local api = vim.api
	api.nvim_create_autocmd({ "User" }, {
		once = true,
		pattern = { "VeryLazy", "LazyVimStarted" },
		desc = "Automatic auth for codeium",
		callback = function()
			vim.schedule(function()
				if require("utils").is_plug_installed("codeium.vim") and not is_authenticated() then
					api.nvim_command("Codeium Auth")
				end
			end)
		end,
	})
end

return M
