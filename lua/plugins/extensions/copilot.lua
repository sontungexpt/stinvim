local M = {
	enabled = true,
}

local is_authenticated = function()
	return vim.fn.filereadable(vim.fn.expand("$HOME") .. "/.config/github-copilot/hosts.json") == 1
end

M.entry = function()
	local api = vim.api
	api.nvim_create_autocmd({ "User" }, {
		once = true,
		pattern = { "VeryLazy", "LazyVimStarted" },
		desc = "Automatic auth for copilot",
		callback = function()
			vim.schedule(function()
				if require("utils").is_plug_installed("copilot.lua") and not is_authenticated() then
					api.nvim_command("Copilot auth")
				end
			end)
		end,
	})
end

return M
