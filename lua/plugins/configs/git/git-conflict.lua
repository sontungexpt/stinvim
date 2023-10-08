local options = {
	default_mappings = {
		ours = "o",
		theirs = "t",
		none = "0",
		both = "b",
		next = "]c",
		prev = "[c",
	},
	default_commands = true, -- disable commands created by this plugin
	disable_diagnostics = true, -- This will disable the diagnostics in a buffer whilst it is conflicted
	highlights = {
		-- They must have background color, otherwise the default color will be used
		incoming = "DiffText",
		current = "DiffAdd",
	},
}

return options
