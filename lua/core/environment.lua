local fn, env = vim.fn, vim.env

local is_windows = vim.loop.os_uname().sysname == "Windows_NT"
local sep = is_windows and ";" or ":"

-- if nvm is installed, add node binaries to path
local function get_nvm_node_bin()
	local nvm_dir = fn.expand("$NVM_DIR")
	local node_dir = fn.empty(nvm_dir) == 0 and nvm_dir .. "/versions/node"
		or is_windows and fn.expand("$HOME") .. "/AppData/Local/nvm/versions/node"
		or fn.expand("$HOME") .. "/.nvm/versions/node"

	if fn.isdirectory(node_dir) == 0 then return nil end

	local node_version = is_windows
			and fn.system("dir /b /ad /o-n " .. node_dir .. ' | findstr /r /b /c:"v"'):gsub("\n", "")
		or fn.system("ls -v " .. node_dir .. " | tail -n 1"):gsub("\n", "")

	return fn.empty(node_version) == 1 and "" or node_dir .. "/" .. node_version .. "/bin"
end

local environments = {
	fn.stdpath("data") .. "/mason/bin", -- add binaries installed by mason.nvim to path
	not env.PATH:find("node") and get_nvm_node_bin() or nil, -- add node binaries to path if not already there
}

env.PATH = table.concat(environments, sep) .. sep .. env.PATH
