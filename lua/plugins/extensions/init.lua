local plug_extension_dir = require("core.genconfs").plug_extension_dir

local files = vim.fn.glob(plug_extension_dir .. "/*.lua", true, true)
local parent_module = string.gsub(string.match(plug_extension_dir, ".-lua/(.*)"), "/", ".")

for _, file in ipairs(files) do
	local filename = vim.fn.fnamemodify(file, ":t:r")
	if filename ~= "init" then
		local status_ok, module = pcall(require, parent_module .. "." .. filename)
		if status_ok and type(module.create_autocmds) == "function" then module.create_autocmds() end
	end
end
