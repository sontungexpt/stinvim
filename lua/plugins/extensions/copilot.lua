local M = {
	enabled = true,
}

M.has_copilot_auth = function()
	return vim.fn.filereadable(vim.fn.expand("$HOME") .. "/.config/github-copilot/hosts.json") == 1
end

M.entry = function()
	local api = vim.api
	api.nvim_create_autocmd({ "User" }, {
		group = api.nvim_create_augroup("CopilotAutoAuth", { clear = true }),
		pattern = "VeryLazy",
		desc = "Automatic auth for copilot",
		callback = function()
			vim.schedule(function()
				if require("utils").is_plug_installed("copilot.lua") and not M.has_copilot_auth() then
					api.nvim_command("Copilot auth")
				end
			end)
		end,
	})
end

return M
