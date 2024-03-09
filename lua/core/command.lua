local new_cmd = vim.api.nvim_create_user_command

new_cmd("NvimHotReload", require("utils.reloader").hot_reload, { nargs = 0 })
new_cmd("NvimTouchPlugExtension", require("utils.plug-extension").touch_plug_extension, { nargs = 0 })
