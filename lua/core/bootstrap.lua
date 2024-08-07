local vim = vim
local api, fn = vim.api, vim.fn

if vim.version().minor < 10 then
	api.nvim_err_writeln("Error: Bootstrap requires at least nvim 0.10")
	return
end

local M = {}

local function echo(str)
	vim.cmd.redraw()
	api.nvim_echo({ { str, "Bold" } }, true, {})
end

function M.lazy(install_path)
	--------- lazy.nvim ---------------
	echo("  Installing lazy.nvim and plugins ...")

	local repo = "https://github.com/folke/lazy.nvim.git"

	vim.system({ "git", "clone", "--filter=blob:none", "--branch=stable", repo, install_path }, nil, function(out)
		vim.schedule(function()
			if out.code == 0 then
				api.nvim_create_autocmd("User", {
					once = true,
					pattern = "LazyDone",
					callback = function()
						echo("󰏔 Plugins installed successfully!")
						require("utils").close_buffers_matching("lazy", "filetype")
					end,
				})

				echo(" lazy.nvim installed successfully!. Loading plugins ...")
				M.boot(install_path)
			else
				api.nvim_err_writeln("Error: Unable to install lazy.nvim and plugins")
			end
		end)
	end)
end

M.load_plugin_extensions = function()
	local plug_extension_dir = vim.g.stinvim_plugin_extension_dir or fn.stdpath("config") .. "/lua/extension"

	local files = fn.glob(plug_extension_dir .. "/*.lua", true, true)

	for _, file in ipairs(files) do
		local module = dofile(file)
		if module.enabled ~= false and type(module.entry) == "function" then module.entry() end
	end
end

function M.boot(install_path)
	local autocmd, augroup, schedule = api.nvim_create_autocmd, api.nvim_create_augroup, vim.schedule

	autocmd("CmdlineEnter", {
		once = true,
		callback = function() require("core.command") end,
	})

	autocmd({ "UIEnter", "BufEnter", "BufNewFile" }, {
		group = augroup("StinvimLazyEvents", {}),
		callback = function(args)
			if args.event == "UIEnter" then vim.g.ui_entered = true end

			if
				vim.g.ui_entered
				and args.file ~= ""
				and api.nvim_get_option_value("buftype", { buf = args.buf }) ~= "nofile"
			then
				api.nvim_del_augroup_by_name("StinvimLazyEvents")
				schedule(function()
					api.nvim_exec_autocmds("User", { pattern = "FilePostLazyLoaded" })
					schedule(function() api.nvim_exec_autocmds("Filetype", { buffer = args.buf }) end)
				end)
			end
		end,
	})

	autocmd("BufEnter", {
		group = augroup("StinvimGitLazyLoad", {}),
		callback = function(args)
			if args.file ~= "" and api.nvim_get_option_value("buftype", { buf = args.buf }) ~= "nofile" then
				api.nvim_del_augroup_by_name("StinvimGitLazyLoad")
				vim.system({ "git", "-C", vim.fs.dirname(args.file), "rev-parse" }, nil, function(out)
					if out.code == 0 then
						schedule(function() api.nvim_exec_autocmds("User", { pattern = "GitLazyLoaded" }) end)
					end
				end)
			end
		end,
	})

	vim.opt.rtp:prepend(install_path)

	M.load_plugin_extensions()

	require("plugins")
end

return M
