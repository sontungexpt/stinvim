local vim = vim
local api, fn = vim.api, vim.fn

local M = {}

local function echo(str)
	vim.cmd("redraw")
	api.nvim_echo({ { str, "Bold" } }, true, {})
end

M.lazy = function(install_path)
	--------- lazy.nvim ---------------
	echo("  Installing lazy.nvim & plugins ...")
	local repo = "https://github.com/folke/lazy.nvim.git"

	fn.jobstart({ "git", "clone", "--filter=blob:none", "--branch=stable", repo, install_path }, {
		on_exit = function(_, code, _)
			if code == 0 then
				M.boot(install_path)
				require("utils").close_buffer("lazy")
			else
				api.nvim_err_writeln("Error: " .. code)
			end
		end,
	})
end

M.load_plugin_extensions = function(install_path)
	local plug_extension_dir = vim.g.stinvim_plugin_extension_dir
		or fn.stdpath("config") .. "/lua/plugins/extensions"

	local files = fn.glob(plug_extension_dir .. "/*.lua", true, true)

	local parent_module = string.gsub(string.match(plug_extension_dir, ".-lua/(.*)"), "/", ".")

	for _, file in ipairs(files) do
		local module = require(parent_module .. "." .. fn.fnamemodify(file, ":t:r") --[[ filename ]])
		if module.enabled ~= false and type(module.create_autocmds) == "function" then
			module.create_autocmds()
		end
	end
end

M.boot = function(install_path)
	local autocmd, augroup, exec_autocmds =
		api.nvim_create_autocmd, api.nvim_create_augroup, api.nvim_exec_autocmds

	autocmd("CmdlineEnter", {
		once = true,
		callback = function() require("core.command") end,
	})

	autocmd({ "UIEnter", "BufReadPost", "BufNewFile" }, {
		group = augroup("StinvimLazyEvents", { clear = true }),
		callback = function(args)
			if args.event == "UIEnter" then vim.g.ui_entered = true end

			if
				vim.g.ui_entered
				and args.file ~= ""
				and api.nvim_buf_get_option(args.buf, "buftype") ~= "nofile"
			then
				vim.schedule(function()
					api.nvim_del_augroup_by_name("StinvimLazyEvents")

					exec_autocmds(
						"User",
						{ pattern = { "FilePostLazyLoadedFast", "KeymapLazyLoaded" }, modeline = false }
					)

					vim.defer_fn(function()
						exec_autocmds("User", { pattern = "FilePostLazyLoaded", modeline = false })
						vim.schedule(function() exec_autocmds("FileType", {}) end, 0)
					end, 50)
				end, 0)
			end
		end,
	})

	autocmd("BufEnter", {
		group = api.nvim_create_augroup("StinvimGitLazyLoad", { clear = true }),
		callback = function(args)
			if args.file ~= "" and api.nvim_buf_get_option(args.buf, "buftype") ~= "nofile" then
				vim.defer_fn(function()
					fn.jobstart({ "git", "-C", fn.expand("%:p:h"), "rev-parse" }, {
						on_exit = function(_, code, _)
							if code == 0 then
								api.nvim_del_augroup_by_name("StinvimGitLazyLoad")
								exec_autocmds("User", { pattern = "GitLazyLoaded", modeline = false })
							end
						end,
					})
				end, 80)
			end
		end,
	})

	vim.opt.rtp:prepend(install_path)

	M.load_plugin_extensions(install_path)

	require("plugins")
end

return M
