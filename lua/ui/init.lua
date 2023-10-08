local colors = require("ui.colors")

local highlight = {
	["DapBreakpoint"] = { fg = colors.red },
	["DapStopped"] = { fg = colors.green },
}

local sign = {
	["DapBreakpoint"] = {
		text = " ",
		texthl = "DapBreakpoint",
	},
	["DapStopped"] = {
		text = "󱞪 ",
		texthl = "DapStopped",
	},
}

local setup = function()
	for k, v in pairs(highlight) do
		vim.api.nvim_set_hl(0, k, v)
	end

	for k, v in pairs(sign) do
		vim.fn.sign_define(k, v)
	end
end

vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
	group = vim.api.nvim_create_augroup("stinvim-ui", { clear = true }),
	callback = setup,
})
