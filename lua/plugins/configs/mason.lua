local options = {
	-- auto sync the installed packages with ensure_installed when open nvim
	auto_sync = true,
	ensure_installed = {
		-- java
		"jdtls",
		"google-java-format",
		"checkstyle",
		"java-debug-adapter",

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
		"cmakelang",
		"codelldb",

		-- python
		"pyright",
		"autopep8",
		"flake8",

		-- others
		"codespell",

		-- web-developments
		-- "prettier",
		"prettierd",
		"eslint-lsp",
		"css-lsp",
		"html-lsp",
		"typescript-language-server",
		-- "deno",
		"emmet-ls",
		"json-lsp",
		"tailwindcss-language-server",
	},
	PATH = "skip",
	ui = {
		check_outdated_packages_on_open = true,
		-- Accepts same border values as |nvim_open_win()|.
		border = "single",
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
