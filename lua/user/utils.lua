local fn, env = vim.fn, vim.env

local M = {}

M.is_terminal = function(terminal_name)
	local term = env.TERM or ""
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

M.hex2rgb = function(hex_color)
	local tonumber = tonumber
	if #hex_color == 4 then
		local r = (tonumber(hex_color:sub(2, 2), 16) * 17) % 256
		local g = (tonumber(hex_color:sub(3, 3), 16) * 17) % 256
		local b = (tonumber(hex_color:sub(4, 4), 16) * 17) % 256
		return r, g, b
	end
	local r = tonumber(hex_color:sub(2, 3), 16)
	local g = tonumber(hex_color:sub(4, 5), 16)
	local b = tonumber(hex_color:sub(6, 7), 16)
	return r, g, b
end

M.compile_lf_colors_file = function(color_file)
	local ansi_color = function(hex_color)
		local r, g, b = M.hex2rgb(hex_color)
		return string.format("38;2;%s;%s;%s", r, g, b)
	end

	-- get the variable from shell
	color_file = color_file
		or (env.LF_CONFIG_HOME and env.LF_CONFIG_HOME .. "/colors")
		or (env.XDG_CONFIG_HOME and env.XDG_CONFIG_HOME .. "/lf/colors")
		or fn.expand("$HOME") .. "/.config/lf/colors"

	local uv = vim.uv or vim.loop
	uv.fs_open(color_file, "r+", 438, function(err, fd)
		if err then return end
		---@diagnostic disable-next-line: redefined-local
		uv.fs_fstat(fd, function(err, stat)
			if err then return end
			---@diagnostic disable-next-line: redefined-local
			uv.fs_read(fd, stat.size, nil, function(err, data)
				if err then return end
				local new_content = data:gsub("#%x%x%x%x%x%x", ansi_color):gsub("#%x%x%x", ansi_color)
				---@diagnostic disable-next-line: redefined-local
				uv.fs_write(fd, new_content, 0, function(err, bytes)
					if err then return end
					---@diagnostic disable-next-line: redefined-local
					uv.fs_close(fd, function(err)
						if err then return end
						vim.schedule(function()
							vim.api.nvim_command("checktime")
							require("utils.notify").info("Compiled lf colors file: " .. color_file)
						end)
					end)
				end)
			end)
		end)
	end)
end

return M
