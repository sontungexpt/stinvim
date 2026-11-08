local vim, pcall = vim, pcall
local noop = function() end

local M = {}

--- Get the root directory of the project.
---
--- @param source string|integer Buffer number (0 for current buffer) or file path to begin the search from
--- @return string|nil: The root directory path of the project
M.find_root = function(source, markers)
    return vim.fs.root(source or 0, markers or vim.g.root_markers or {
        ".git",
        "package.json", -- npm
        "Cargo.toml", -- rust
        "build.zig", -- zig
        "stylua.toml", -- lua
        "lazy-lock.json", -- nvim config
        "gradlew",  -- java
        "mvnw",     -- java
    })
end

do
    local EMPTY_MODULE
    local proxy = function() return EMPTY_MODULE end
    EMPTY_MODULE = setmetatable({}, {
        __index = proxy,
        __call = proxy,
        __newindex = noop,
    })

    --- Safely loads a module, returning its contents if successful or a no-op proxy otherwise.
    ---
    --- The fallback proxy silently ignores field access, function calls, and assignments,
    --- including chained operations, when the requested module cannot be loaded.
    ---
    --- @param name string The name of the module to load.
    --- @return table module The loaded module or an empty no-op proxy.
    M.safe_require = function(name)
        local ok, module = pcall(require, name)
        if ok then
            return module
        end
        require("utils.notify").error("Module " .. name .. " not found")
        return EMPTY_MODULE
    end
end

return setmetatable(M, {
    __index = function(_, key) return require("utils." .. key) end,
})
