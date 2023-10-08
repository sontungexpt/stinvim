local M = {}

-- File to identify project root
M.root_markers = {
	-- rust
	"Cargo.toml",

	-- lua
	"stylua.toml",

	-- git
	".git",

	-- npm
	"package.json",

	-- nvim config
	"lazy-lock.json",

	-- java
	"gradlew",
	"mvnw",
}

return M
