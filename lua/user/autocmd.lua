local api = vim.api
local fn = vim.fn
local autocmd = api.nvim_create_autocmd
local augroup = api.nvim_create_augroup

autocmd({ "VimEnter" }, {
	group = augroup("AutocdConfigFolderRoot", { clear = true }),
	pattern = fn.stdpath("config") .. "/**",
	command = "cd " .. fn.stdpath("config"),
	desc = "Auto change directory to config folder - support for nvimconfig alias",
})

autocmd({ "BufWritePost" }, {
	group = augroup("ScriptBuilder", { clear = true }),
	desc = "Compile scripts in ~/scripts/stilux/systems",
	pattern = { fn.expand("$HOME") .. "/scripts/stilux/systems/*" },
	callback = require("user.utils").compile_stilux_srcipt_file,
})

autocmd("FileType", {
	group = augroup("OpenApiDoc", { clear = true }),
	pattern = { "java" },
	callback = function(args)
		api.nvim_create_user_command("OpenApiDoc", function()
			fn.jobstart("xdg-open http://localhost:8080/swagger-ui/index.html", {
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
