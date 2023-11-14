local api = vim.api
local fn = vim.fn

local LazyLoader = {}

LazyLoader.load_on_file_open = function(plugin)
	api.nvim_create_autocmd({ "BufRead", "BufWinEnter", "BufNewFile" }, {
		group = api.nvim_create_augroup("BeLazyOnFileOpen" .. plugin, {}),
		callback = function()
			local file = fn.expand("%")
			local condition = file ~= "NvimTree_1" and file ~= "[lazy]" and file ~= ""

			if condition then
				api.nvim_del_augroup_by_name("BeLazyOnFileOpen" .. plugin)

				-- dont defer for treesitter as it will show slow highlighting
				-- This deferring only happens only when we do "nvim filename"
				if plugin ~= "nvim-treesitter" then
					vim.schedule(function()
						require("lazy").load { plugins = plugin }
						if plugin == "nvim-lspconfig" then vim.cmd.doautocmd("FileType") end
					end)
				else
					require("lazy").load { plugins = plugin }
				end
			end
		end,
	})
end

LazyLoader.load_on_repo_open = function(plugin)
	api.nvim_create_autocmd({ "BufReadPost" }, {
		group = api.nvim_create_augroup("BeLazyLoadOnGitRepoOpen" .. plugin, { clear = true }),
		callback = function()
			fn.system("git -C " .. '"' .. fn.expand("%:p:h") .. '"' .. " rev-parse")
			if vim.v.shell_error == 0 then
				api.nvim_del_augroup_by_name("BeLazyLoadOnGitRepoOpen" .. plugin)
				vim.schedule(function() require("lazy").load { plugins = plugin } end)
			end
		end,
	})
end

return LazyLoader
