local vim = vim

local biome_prettier = { "biome", "prettierd", "prettier", stop_after_first = true }
local prettier = { "prettierd", "prettier", stop_after_first = true }

-- ConformFormat user command
vim.api.nvim_create_user_command("ConformFormat", function(args)
    local range = nil
    if args.count ~= -1 then
        local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
        range = {
            start = { args.line1, 0 },
            ["end"] = { args.line2, end_line:len() },
        }
    end
    require("conform").format { async = true, lsp_format = "fallback", range = range }
end, { range = true })

-- ---------------------------------------------------- Formatting ----------------------------------------------------
-- Code formatting plugins.
-- Mission: Auto-format source code on save or on demand (conform.nvim with formatters per filetype).
return {
    {
        "stevearc/conform.nvim",
        cmd = "ConformInfo",
        event = { "BufWritePre", "BufReadPost", },
        main = "conform",
        opts = {
            formatters_by_ft = {
                lua = { "stylua" },
                python = { "ruff_format", "autopep8", stop_after_first = true },
                xml = { "xmlformatter" },
                go = { "goimports", "gofumpt" },
                http = { "kulala-fmt" },
                rest = { "kulala-fmt" },
                kt = { "ktlint" },
                javascript = biome_prettier,
                typescript = biome_prettier,
                javascriptreact = biome_prettier,
                typescriptreact = biome_prettier,
                json = biome_prettier,
                jsonc = biome_prettier,
                css = prettier,
                html = prettier,
                markdown = prettier,
                yaml = prettier,
                c = { "clang_format" },
                cpp = { "clang_format" },
                rust = { "rustfmt", "leptosfmt", stop_after_first = true },
                zig = { "zigfmt" },
                sh = { "shfmt", stop_after_first = true },
                toml = { "taplo" },
                java = { "google-java-format" },
            },
            default_format_opts = {
                lsp_format = "fallback",
            },
            format_on_save = function(bufnr)
                -- Don't format on save for very large files to avoid blocking
                local max_lines = 10000
                if vim.api.nvim_buf_line_count(bufnr) > max_lines then
                    return nil
                end
                return {
                    timeout_ms = 1000,
                    lsp_format = "fallback",
                }
            end,
            format_after_save = function(bufnr)
                -- Only format after save for filetypes that have slow formatters
                local slow_ft = { python = true, go = true, rust = true }
                if not slow_ft[vim.bo[bufnr].filetype] then
                    return nil
                end
                return {
                    lsp_format = "fallback",
                }
            end,
            log_level = vim.log.levels.ERROR,
            notify_on_error = true,
            notify_no_formatters = true,
        },
    },

}
