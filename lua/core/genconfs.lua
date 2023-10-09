local M = {}

-- File to identify project root
M.root_markers = {
	".git",
	"package.json", -- npm
	"Cargo.toml", -- rust
	"stylua.toml", -- lua
	"lazy-lock.json", -- nvim config
	"gradlew", -- java
	"mvnw", -- java
}

M.templates_dir_path = vim.fn.stdpath("config") .. "/templates"
M.plug_autocmds_dir_path = vim.fn.stdpath("config") .. "/lua/plugins/autocmds"

return M
