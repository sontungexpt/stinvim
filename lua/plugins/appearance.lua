-- ------------------------------------------------- Appearance -------------------------------------------------
-- Theme, colorscheme, statusline, and visual styling plugins.
-- Mission: Control how the editor looks (themes, statusline).
return {
    {
        "sontungexpt/witch-line",
        lazy = false,
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        opts = {
            auto_theme = false,
        },
    },
    {
        dir = "/home/stilux/Data/workspace/neovim-plugins/witch",
        priority = 1000,
        lazy = false,
        main = "witch",
        opts = {
            theme = {
                enabled = true,
                style = "dark",
                extras = {},
                customs = {},
                on_highlight = function(style, colors, highlight) end,
            },
            dim_inactive = {
                enabled = true,
                level = 0.48,
                excluded = {
                    filetypes = { NvimTree = true },
                    buftypes = { nofile = true, prompt = true, terminal = true },
                },
            },
            switcher = true,
            more_themes = {},
        }
    },
}
