-- key: command name
-- value: table
-- value[1]: function to do
-- value[2]: table opts
local commands = {
	["NvimHotReload"] = { require("utils.reloader").hot_reload },
	["NvimTouchPlugExtension"] = {
		require("utils.plug-extension").touch_plug_extension,
	},
}

for cmd_name, v in pairs(commands) do
	vim.api.nvim_create_user_command(cmd_name, v[1], v[2] or { nargs = 0 })
	commands[cmd_name] = nil
end
