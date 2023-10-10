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
	callback = function()
		local function check_and_insert_lines(file_name)
			local line1 = 'YAY="yay -S --answerclean All --noconfirm --needed"'
			local line2 = 'PACMAN="sudo pacman -S --noconfirm --needed"'
			local file = io.open(file_name, "r+")
			local lines = {}

			-- a index line begin from 1
			local line_index = 1
			local is_replaced = false
			if file then
				for line in file:lines() do
					if line_index > 1 then
						if not is_replaced and not (line:match("^%s*#")) then
							line = "\n" .. line1 .. "\n" .. line2 .. "\n\n" .. line
							is_replaced = true
						end
					end
					lines[line_index] = line
					line_index = line_index + 1
				end
				local new_content = table.concat(lines, "\n")
				file:seek("set")
				file:write(new_content)
				file:close()
			end
		end

		local file_path = fn.expand("%:p")
		local file_name = fn.expand("%:t")
		local sys_build_dir = fn.expand("$HOME") .. "/scripts/stilux/systems-build"
		local copy_file_path = sys_build_dir .. "/" .. file_name

		local command = string.format(
			"mkdir -p %s && cp %s %s && sed -i -e 's/\\(sudo \\)\\?yay -S\\( --needed\\)\\? \\(\\S.*\\)/eval \"$YAY \\3\"/g' %s && sed -i -e 's/\\(sudo \\)\\?pacman -S\\( --needed\\)\\? \\(\\S.*\\)/eval \"$PACMAN \\3\"/g' %s",
			sys_build_dir,
			file_path,
			copy_file_path,
			copy_file_path,
			copy_file_path
		)

		fn.jobstart(command, {
			on_exit = function(_, exit_code, _)
				if exit_code == 0 then
					vim.schedule(function() check_and_insert_lines(copy_file_path) end)
				else
					print("Error: " .. exit_code)
				end
			end,
		})
	end,
})
