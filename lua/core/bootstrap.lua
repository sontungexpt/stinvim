local vim = vim
local api, fn = vim.api, vim.fn

local M = {}

local function echo(str)
	vim.cmd.redraw()
	api.nvim_echo({ { str, "Bold" } }, true, {})
end

M.lazy = function(install_path)
	--------- lazy.nvim ---------------
	echo("  Installing lazy.nvim and plugins ...")

	local repo = "https://github.com/folke/lazy.nvim.git"
	fn.jobstart({ "git", "clone", "--filter=blob:none", "--branch=stable", repo, install_path }, {
		on_exit = function(_, code)
			if code == 0 then
				api.nvim_create_autocmd("User", {
					once = true,
					pattern = "LazyDone",
					callback = function()
						echo("󰏔 Plugins installed successfully!")
						require("utils").close_buffers_matching("lazy", "filetype")
					end,
				})

				echo(" lazy.nvim installed successfully!")
				M.boot(install_path)
			else
				api.nvim_err_writeln("Error: Unable to install lazy.nvim and plugins")
			end
		end,
	})
end

M.load_plugin_extensions = function()
	local plug_extension_dir = vim.g.stinvim_plugin_extension_dir
		or fn.stdpath("config") .. "/lua/plugins/extensions"

	local files = fn.glob(plug_extension_dir .. "/*.lua", true, true)

	for _, file in ipairs(files) do
		local module = dofile(file)
		if module.enabled ~= false and type(module.entry) == "function" then module.entry() end
	end
end

M.boot = function(install_path)
	local autocmd, augroup = api.nvim_create_autocmd, api.nvim_create_augroup

	autocmd("CmdlineEnter", {
		once = true,
		callback = function() require("core.command") end,
	})

	autocmd({ "UIEnter", "BufEnter", "BufNewFile" }, {
		group = augroup("StinvimLazyEvents", { clear = true }),
		callback = function(args)
			if args.event == "UIEnter" then vim.g.ui_entered = true end

			if
				vim.g.ui_entered
				and args.file ~= ""
				and api.nvim_buf_get_option(args.buf, "buftype") ~= "nofile"
			then
				api.nvim_del_augroup_by_name("StinvimLazyEvents")
				vim.schedule(function()
					api.nvim_exec_autocmds("User", { pattern = "FilePostLazyLoaded", modeline = false })
					vim.schedule(function() api.nvim_exec_autocmds("Filetype", { buffer = args.buf }) end, 100)
				end, 100)
			end
		end,
	})

	autocmd("BufEnter", {
		group = augroup("StinvimGitLazyLoad", { clear = true }),
		callback = function(args)
			if args.file ~= "" and api.nvim_buf_get_option(args.buf, "buftype") ~= "nofile" then
				api.nvim_del_augroup_by_name("StinvimGitLazyLoad")
				vim.schedule(function()
					fn.jobstart({ "git", "-C", fn.expand("%:p:h"), "rev-parse" }, {
						on_exit = function(_, code)
							if code == 0 then
								api.nvim_exec_autocmds("User", { pattern = "GitLazyLoaded", modeline = false })
							end
						end,
					})
				end, 100)
			end
		end,
	})

	vim.opt.rtp:prepend(install_path)

	M.load_plugin_extensions()

	require("plugins")
end

return M
