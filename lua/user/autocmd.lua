local api, fn = vim.api, vim.fn
local autocmd, expand = api.nvim_create_autocmd, fn.expand
local group = api.nvim_create_augroup("UserAutocmd", { clear = true })

local config_dir = fn.stdpath("config")

autocmd("VimEnter", {
	group = group,
	pattern = config_dir .. "/**",
	command = "cd " .. config_dir,
	desc = "Auto change directory to config folder - support for nvimconfig alias",
})

if vim.env.TERM == "alacritty" then
	autocmd({ "VimEnter", "VimLeave", "FocusLost", "FocusGained" }, {
		group = group,
		desc = "Switch ibus engine",
		callback = function(args)
			local engines = {
				VimEnter = "BambooUs",
				FocusGained = "BambooUs",
				VimLeave = "Bamboo",
				FocusLost = "Bamboo",
			}
			vim.system({ "ibus", "engine", engines[args.event] }, {}, function(out)
				if out.code == 0 then require("utils.notify").info("Switched ibus engine to " .. engines[args.event]) end
			end)
		end,
	})
end

autocmd("BufWritePost", {
	group = group,
	desc = "Compile scripts in ~/scripts/stilux/systems",
	pattern = expand("$HOME") .. "/scripts/stilux/systems/*",
	callback = function() require("user.utils").compile_stilux_srcipt_file() end,
})

autocmd("BufWritePost", {
	group = group,
	pattern = {
		expand("$HOME/.config/lf/colors"),
		expand("$LF_CONFIG_HOME/colors"),
		expand("$XDG_CONFIG_HOME/lf/colors"),
	},
	callback = function(args) require("user.utils").compile_lf_colors_file(args.file) end,
})
