local api, fn, env = vim.api, vim.fn, vim.env
local autocmd = api.nvim_create_autocmd
local group = api.nvim_create_augroup("UserAutocmd", { clear = true })

autocmd("VimEnter", {
	group = group,
	pattern = fn.stdpath("config") .. "/**",
	command = "cd " .. fn.stdpath("config"),
	desc = "Auto change directory to config folder - support for nvimconfig alias",
})

autocmd({ "VimEnter", "VimLeave", "FocusLost", "FocusGained" }, {
	group = group,
	desc = "Switch ibus engine",
	callback = function(args)
		if env.TERM == "alacritty" then
			local engines = {
				VimEnter = "BambooUs",
				FocusGained = "BambooUs",
				VimLeave = "Bamboo",
				FocusLost = "Bamboo",
			}

			fn.jobstart({ "ibus", "engine", engines[args.event] }, {
				on_exit = function(_, code)
					if code == 0 then
						require("utils.notify").info("Switched ibus engine to " .. engines[args.event])
					end
				end,
			})
		end
	end,
})

autocmd("BufWritePost", {
	group = group,
	desc = "Compile scripts in ~/scripts/stilux/systems",
	pattern = fn.expand("$HOME") .. "/scripts/stilux/systems/*",
	callback = function() require("user.utils").compile_stilux_srcipt_file() end,
})

autocmd("BufWritePost", {
	group = group,
	pattern = {
		fn.expand("$HOME") .. "/.config/lf/colors",
		env.LF_CONFIG_HOME and env.LF_CONFIG_HOME .. "/colors",
		env.XDG_CONFIG_HOME and env.XDG_CONFIG_HOME .. "/lf/colors",
	},
	callback = function(args) require("user.utils").compile_lf_colors_file(args.file) end,
})

autocmd("FileType", {
	group = group,
	pattern = "java",
	callback = function(args)
		api.nvim_create_user_command("OpenApiDoc", function()
			fn.jobstart({ "xdg-open", "http://localhost:8080/swagger-ui/index.html" }, {
				detach = true,
				on_exit = function(_, code, _)
					if code ~= 0 then
						require("utils.notify").error("Failed to open swagger-ui")
					else
						require("utils.notify").info("Opening http://localhost:8080/swagger-ui/index.html")
					end
				end,
			})
		end, { nargs = 0 })
		require("utils.mapper").map("n", "<leader>po", ":OpenApiDoc<CR>", { buffer = args.buf })
	end,
})
