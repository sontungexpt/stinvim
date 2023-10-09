-- key: command name
-- value: table
-- value[1]: function to do
-- value[2]: table opts
local commands = {
	["NvimHotReload"] = { function() require("utils.reloader").hot_reload() end, { nargs = 0 } },
	["NvimTouchPlugAutocmd"] = {
		function() require("utils.plug-autocmd").touch_plug_autocmd() end,
		{ nargs = 0 },
	},
}

for cmd_name, v in pairs(commands) do
	vim.api.nvim_create_user_command(cmd_name, v[1], v[2])
	commands[cmd_name] = nil
end
