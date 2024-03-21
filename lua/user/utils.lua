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
	local file_path, file_name, build_dir =
		fn.expand("%:p"), fn.expand("%:t"), fn.expand("$HOME") .. "/scripts/stilux/systems-build"
	local build_file_path = build_dir .. "/" .. file_name

	local handle_command = function(line)
		if line == "" then return "" end

		local require_args = {
			yay = {
				-- arg = value or true if value is nil
				-- arg = false mean this arg is not require so need to be remove
				["--noconfirm"] = true,
				["--needed"] = true,
				["--answerclean"] = "All",
			},
			pacman = {
				["--noconfirm"] = true,
				["--needed"] = true,
			},
		}
		local args = {}
		local args_length = 0

		local should_be_arg = false
		for arg in line:gmatch("%S+") do
			if not should_be_arg then
				if args_length == 0 then
					if require_args[arg] then
						should_be_arg = true
						require_args = require_args[arg]
					elseif arg ~= "sudo" then
						return line
					end
				elseif args_length == 1 and require_args[arg] then
					should_be_arg = true
					require_args = require_args[arg]
				else
					return line
				end
				args_length = args_length + 1
				args[args_length] = arg
			else -- after found command then add args
				if require_args[arg] ~= false then
					args_length = args_length + 1
					args[args_length] = arg
				end
				require_args[arg] = nil
			end
		end

		for arg, value in pairs(require_args) do
			args_length = args_length + 1
			args[args_length] = arg
			if type(value) == "string" then
				args_length = args_length + 1
				args[args_length] = value
			end
		end

		return table.concat(args, " ")
	end

	fn.mkdir(build_dir, "p")

	local uv = vim.uv or vim.loop
	---@diagnostic disable: redefined-local
	uv.fs_open(file_path, "r", 438, function(err, fd)
		if err then return end
		uv.fs_fstat(fd, function(err, stat)
			if err then return end
			uv.fs_read(fd, stat.size, nil, function(err, data)
				if err then return end
				local lines = vim.split(data, "\n")
				for i, line in ipairs(lines) do
					lines[i] = handle_command(line)
				end
				uv.fs_close(fd, function(err)
					if err then return end
					uv.fs_open(build_file_path, "w", 438, function(err, fd)
						uv.fs_write(fd, table.concat(lines, "\n"), 0, function(err, bytes)
							if err then return end
							uv.fs_close(fd, function(err)
								if err then return end
								require("utils.notify").info("Compiled: " .. file_name)
							end)
						end)
					end)
				end)
			end)
		end)
	end)
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
