local colors = require("ui.colors")
local no_seps = require("ui.lualine").no_seps

-- https://www.nerdfonts.com/cheat-sheet
local icons = {
	["utf-8"] = "󰉿",
	["utf-16"] = "",
	["utf-32"] = "",
	["utf-8mb4"] = "",
	["utf-16le"] = "",
	["utf-16be"] = "",
}

local encoding = function()
	local enc = vim.bo.fenc ~= "" and vim.bo.fenc or vim.o.enc
	return icons[enc] or enc
end

return {
	encoding,
	separator = no_seps,
	padding = 1,
	color = { bg = colors.yellow, fg = colors.black },
}
