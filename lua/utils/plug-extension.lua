local fn = vim.fn

local M = {}

local copy_file_content = function(source, target)
	local source_file = io.open(source, "r")
	if source_file then
		local content = source_file:read("*all")
		source_file:close()

		local target_file = io.open(target, "w")
		if target_file then
			target_file:write(content)
			target_file:close()
			return true
		else
			return false
		end
	end
end

M.touch_plug_extension = function(filename)
	if type(filename) ~= "string" then filename = fn.input("Enter the filename: ", "", "file") end

	if filename == "" then
		require("utils.notify").warn("No filename given")
		return
	elseif not filename:match("%.lua$") then
		filename = fn.fnamemodify(filename, ":r") .. ".lua"
	end

	local new_file_path = (
		vim.g.stinvim_plugin_extension_dir or vim.fn.stdpath("config") .. "/lua/plugins/extensions"
	)
		.. "/"
		.. filename

	if fn.filereadable(new_file_path) == 1 then
		require("utils.notify").warn("File already exists: " .. filename)
		return
	end

	local status_ok =
		copy_file_content(vim.fn.stdpath("config") .. "/templates/plug_autocmd.txt", new_file_path)
	if status_ok then
		require("utils.notify").info("Created file: " .. filename)
	else
		require("utils.notify").error("Unable to create file: " .. filename)
	end
end

return M
