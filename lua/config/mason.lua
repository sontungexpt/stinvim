return {
	-- auto sync the installed packages with ensure_installed when open nvim
	auto_sync = true,
	ui = {
		check_outdated_packages_on_open = true,
		border = "single", -- Accepts same border values as |nvim_open_win()|.
		width = 0.8,
		height = 0.9,
		icons = {
			package_pending = " ",
			package_installed = " ",
			package_uninstalled = " ",
		},
	},
	max_concurrent_installers = 10,
}
