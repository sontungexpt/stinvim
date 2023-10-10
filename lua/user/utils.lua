local fn = vim.fn

local M = {}

M.is_terminal = function(terminal_name)
	local term = vim.env.TERM or ""
	return term:lower() == terminal_name
end

M.switch_language_engine = function(engine)
	local current_engine = fn.system("ibus engine"):gsub("%s+", "")
	if current_engine ~= engine then
		local engines = fn.system("ibus list-engine"):gsub("%s+", "")
		if engines:find(engine) then
			fn.system("ibus engine " .. engine)
		else
			require("utils.notify").error("Engine not found: " .. engine)
		end
	end
end

M.compile_stilux_srcipt_file = function()
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
				vim.schedule(function()
					local line1 = 'YAY="yay -S --answerclean All --noconfirm --needed"'
					local line2 = 'PACMAN="sudo pacman -S --noconfirm --needed"'
					local content_lines = {}

					local line_index = 1
					local is_replaced = false

					for line in io.lines(copy_file_path) do
						if line_index > 1 then
							if not is_replaced and not (line:match("^%s*#")) then
								line = "\n" .. line1 .. "\n" .. line2 .. "\n\n" .. line
								is_replaced = true
							end
						end
						content_lines[line_index] = line
						line_index = line_index + 1
					end

					local file = io.open(copy_file_path, "w")
					if file then
						file:write(table.concat(content_lines, "\n"))
						file:close()
					end
				end)
			else
				require("utils.notify").error("Can not execute command: " .. exit_code)
			end
		end,
	})
end

return M
