local options = {
	-- auto sync the installed packages with ensure_installed when open nvim
	auto_sync = true,

	-- I recommend you create .masonrc.json file instead using this key to make the command MasonSyncPackages working
	ensure_installed = {
		-- lua
		"lua-language-server",
		"stylua",

		-- bash
		"bash-language-server",
		"shfmt",
		"shellcheck",

		-- toml
		"taplo",

		-- c++
		"clangd",
		"clang-format",
		"cmake-language-server",
		"codelldb",

		-- python
		"pyright",
		"autopep8",

		-- others
		"codespell",

		-- web-developments
		-- "prettier",
		"prettierd",
		"eslint-lsp",
		"css-lsp",
		"html-lsp",
		"typescript-language-server",
		"emmet-ls",
		"json-lsp",
		"tailwindcss-language-server",

		-- java
		"jdtls",
		"google-java-format",
		"java-debug-adapter",
	},
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

return options
