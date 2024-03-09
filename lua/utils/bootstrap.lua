local vim = vim
local api = vim.api
local fn = vim.fn
local autocmd = api.nvim_create_autocmd
local augroup = api.nvim_create_augroup

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

M.lazy = function(install_path)
	--------- lazy.nvim ---------------
	echo("  Installing lazy.nvim & plugins ...")
	local repo = "https://github.com/folke/lazy.nvim.git"
	shell_call { "git", "clone", "--filter=blob:none", "--branch=stable", repo, install_path }

	M.load_plugins(install_path)
end

M.load_plugin_extensions = function(install_path)
	local plug_extension_dir = vim.g.stinvim_plugin_extension_dir
		or vim.fn.stdpath("config") .. "/lua/plugins/extensions"

	local files = vim.fn.glob(plug_extension_dir .. "/*.lua", true, true)

	local parent_module = string.gsub(string.match(plug_extension_dir, ".-lua/(.*)"), "/", ".")

	for _, file in ipairs(files) do
		local filename = vim.fn.fnamemodify(file, ":t:r")
		local status_ok, module = pcall(require, parent_module .. "." .. filename)
		if status_ok and type(module.create_autocmds) == "function" then module.create_autocmds() end
	end
end

M.load_plugins = function(install_path)
	vim.opt.rtp:prepend(install_path)

	-- setup autocmds for lazy loading
	autocmd({ "UIEnter", "BufReadPost", "BufNewFile" }, {
		group = augroup("StinvimFilePost", { clear = true }),
		callback = function(args)
			local file = api.nvim_buf_get_name(args.buf)
			local buftype = api.nvim_buf_get_option(args.buf, "buftype")

			if not vim.g.ui_entered and args.event == "UIEnter" then vim.g.ui_entered = true end

			if file ~= "" and buftype ~= "nofile" and vim.g.ui_entered then
				api.nvim_exec_autocmds("User", { pattern = "FilePostLazyLoaded", modeline = false })
				api.nvim_del_augroup_by_name("StinvimFilePost")

				vim.schedule(function() api.nvim_exec_autocmds("FileType", {}) end, 0)
			end
		end,
	})

	autocmd("BufReadPost", {
		group = api.nvim_create_augroup("StinvimGitLazyLoad", { clear = true }),
		callback = function()
			fn.system("git -C " .. '"' .. fn.expand("%:p:h") .. '"' .. " rev-parse")
			if vim.v.shell_error == 0 then
				api.nvim_del_augroup_by_name("StinvimGitLazyLoad")
				api.nvim_exec_autocmds("User", { pattern = "GitLazyLoaded", modeline = false })
			end
		end,
	})

	M.load_plugin_extensions(install_path)

	require("plugins")
end

return M
