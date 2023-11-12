local fn = vim.fn

local function get_node_bin()
	local nvm_dir = fn.expand("$NVM_DIR")
	local node_dir = fn.empty(nvm_dir) == 1 and fn.expand("$HOME") .. "/.nvm/versions/node"
		or nvm_dir .. "/versions/node"
	if fn.isdirectory(node_dir) == 0 then return "" end
	local node_version = fn.system("ls -v " .. node_dir .. " | tail -n 1")
	return fn.empty(node_version) == 1 and "" or node_dir .. "/" .. node_version .. "/bin/node"
end

-- add more environment paths here
local environment_paths = {
	fn.stdpath("data") .. "/mason/bin", -- add binaries installed by mason.nvim to path
	get_node_bin(), -- add node to path if using nvm to manage node versions
}

local separator = vim.loop.os_uname().sysname == "Windows_NT" and ";" or ":"
vim.env.PATH = table.concat(environment_paths, separator) .. separator .. vim.env.PATH
