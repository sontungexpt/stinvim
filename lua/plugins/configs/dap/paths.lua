local M = {}

M.get_adapter_mason_path = function(adapter_name, custom_path)
	return require("mason-registry").get_package(adapter_name):get_install_path()
		.. "/"
		.. (custom_path or adapter_name)
end

M.get_rust_debug_filepath = function()
	local project_dir = require("utils").find_root()

	-- check if project_dir end with / then remove it
	if vim.endswith(project_dir, "/") then project_dir = project_dir:sub(1, -2) end

	return project_dir .. "/target/debug/" .. vim.fn.fnamemodify(project_dir, ":p:h:t")
end

return M
