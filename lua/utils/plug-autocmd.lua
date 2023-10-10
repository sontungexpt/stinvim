local fn = vim.fn

local M = {}

M.touch_plug_autocmd = function()
	local filename = fn.input("Enter the filename: ", "", "file")

	if filename == "" then
		require("utils.notify").warn("No filename given")
		return
	end

	if not filename:match("%.lua$") then filename = fn.fnamemodify(filename, ":r") .. ".lua" end

	local new_file_path = require("core.genconfs").plug_autocmds_dir .. "/" .. filename

	if fn.filereadable(new_file_path) == 1 then
		require("utils.notify").warn("File already exists: " .. filename)
		return
	end

	local status_ok = require("utils").copy_file_content(
		require("core.genconfs").templates_dir .. "/plug_autocmd.txt",
		new_file_path
	)
	if status_ok then
		require("utils.notify").info("Created file: " .. filename)
	else
		require("utils.notify").error("Unable to create file: " .. filename)
	end
end

return M
