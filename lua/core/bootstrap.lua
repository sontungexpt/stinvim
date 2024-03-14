local vim = vim
local api, fn, defer_fn, schedule = vim.api, vim.fn, vim.defer_fn, vim.schedule
local autocmd, augroup, nvim_exec_autocmds =
	api.nvim_create_autocmd, api.nvim_create_augroup, api.nvim_exec_autocmds

local M = {}

local function echo(str)
	vim.cmd("redraw")
	api.nvim_echo({ { str, "Bold" } }, true, {})
end

local function shell_call(args)
	local output = fn.system(args)
	assert(
		vim.v.shell_error == 0,
		"External call failed with error code: " .. vim.v.shell_error .. "\n" .. output
	)
end

M.load_commands = function()
	local new_cmd = vim.api.nvim_create_user_command

	new_cmd("NvimHotReload", require("utils.reloader").hot_reload, { nargs = 0 })
	new_cmd("NvimTouchPlugExtension", require("utils.plug-extension").touch_plug_extension, { nargs = 0 })
end

M.lazy = function(install_path)
	--------- lazy.nvim ---------------
	echo("  Installing lazy.nvim & plugins ...")
	local repo = "https://github.com/folke/lazy.nvim.git"
	shell_call { "git", "clone", "--filter=blob:none", "--branch=stable", repo, install_path }

	M.boot(install_path)
end

M.load_plugin_extensions = function(install_path)
	local plug_extension_dir = vim.g.stinvim_plugin_extension_dir
		or fn.stdpath("config") .. "/lua/plugins/extensions"

	local files = fn.glob(plug_extension_dir .. "/*.lua", true, true)

	local parent_module = string.gsub(string.match(plug_extension_dir, ".-lua/(.*)"), "/", ".")

	for _, file in ipairs(files) do
		local module = require(parent_module .. "." .. fn.fnamemodify(file, ":t:r") --[[ filename ]])
		if type(module.create_autocmds) == "function" then module.create_autocmds() end
	end
end

M.boot = function(install_path)
	vim.opt.rtp:prepend(install_path)

	-- setup autocmds for lazy loading
	autocmd({ "UIEnter", "BufReadPost", "BufNewFile" }, {
		group = augroup("StinvimFilePost", { clear = true }),
		callback = function(args)
			if args.event == "UIEnter" then vim.g.ui_entered = true end

			if
				api.nvim_buf_get_name(args.buf) ~= ""
				and api.nvim_buf_get_option(args.buf, "buftype") ~= "nofile"
				and vim.g.ui_entered
			then
				schedule(function()
					nvim_exec_autocmds("User", { pattern = "FilePostLazyLoadedFast", modeline = false })
					defer_fn(function()
						nvim_exec_autocmds("User", { pattern = "FilePostLazyLoaded", modeline = false })
						api.nvim_del_augroup_by_name("StinvimFilePost")
						schedule(function() nvim_exec_autocmds("FileType", {}) end, 0)
					end, 50)
					M.load_commands()
				end, 0)
			end
		end,
	})

	autocmd("BufReadPost", {
		group = api.nvim_create_augroup("StinvimGitLazyLoad", { clear = true }),
		callback = function()
			defer_fn(function()
				fn.system("git -C " .. '"' .. fn.expand("%:p:h") .. '"' .. " rev-parse")
				if vim.v.shell_error == 0 then
					api.nvim_del_augroup_by_name("StinvimGitLazyLoad")
					nvim_exec_autocmds("User", { pattern = "GitLazyLoaded", modeline = false })
				end
			end, 50)
		end,
	})

	M.load_plugin_extensions(install_path)

	require("plugins")
end

return M
