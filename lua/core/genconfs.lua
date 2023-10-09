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

return M
