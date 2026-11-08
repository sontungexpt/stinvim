local vim = vim
local api, uv = vim.api, vim.uv

if vim.version().minor < 10 then
    api.nvim_echo({ { "Error: Bootstrap requires at least nvim 0.10", "Error" } }, false, { err = true })
    return
end

local M = {}

local function echo(str, opts)
    vim.cmd.redraw()
    api.nvim_echo({ { str, "Bold" } }, false, opts)
end

local function do_boot(install_path)
    vim.opt.rtp:prepend(install_path)

    require("lazy").setup("plugins", {
        defaults = {
            lazy = true,
            version = false,
        },
        ui = {
            -- size = { width = 0.8, height = 0.8 },
            wrap = true,
            border = "single",
        },
        performance = {
            rtp = {
                disabled_plugins = {
                    "2html_plugin",
                    "getscript",
                    "getscriptPlugin",
                    "gzip",
                    "logiPat",

                    -- disable netrw
                    "netrw",
                    "netrwPlugin",
                    "netrwSettings",
                    "netrwFileHandlers",
                    "netrw_gitignore",

                    "matchit",
                    "tar",
                    "tarPlugin",
                    "rrhelper",
                    "spellfile_plugin",
                    "spellfile",
                    "vimball",
                    "vimballPlugin",
                    "tutor_mode_plugin",
                    "remote_plugins",
                    "synmenu",
                    "optwin",
                    "compiler",
                    "bugreport",
                    "zip",
                    "zipPlugin",
                },
            },
        },
    })

    -- Trigger lazy loading events after UI is ready
    local boot_lazy_grp = api.nvim_create_augroup("__core_lazy_boot__", { clear = true })

    local file_post_handler
    file_post_handler = api.nvim_create_autocmd({ "UIEnter", "BufEnter", "BufNewFile" }, {
        group = boot_lazy_grp,
        callback = function(args)
            if not api.nvim_buf_is_valid(args.buf) then
                args.buf = api.nvim_get_current_buf()
            end

            local file = api.nvim_buf_get_name(args.buf)
            local buftype = api.nvim_get_option_value("buftype", { buf = args.buf })

            if args.event == "UIEnter" then
                vim.g.ui_entered = true
            end

            if vim.g.ui_entered and file ~= "" and buftype ~= "nofile" then
                api.nvim_del_autocmd(file_post_handler)
                api.nvim_exec_autocmds("User", { pattern = "FileLazyLoaded" })
                vim.schedule(function()
                    api.nvim_exec_autocmds("FileType", { buffer = args.buf })
                end)
            end
        end,
    })

    -- Detect git repositories for lazy loading
    local git_detect_handler
    git_detect_handler = api.nvim_create_autocmd("BufEnter", {
        group = boot_lazy_grp,
        callback = function(args)
            local buf_name = vim.api.nvim_buf_get_name(args.buf)
            if buf_name == "" or vim.bo[args.buf].buftype == "nofile" then
                return
            end
            api.nvim_del_autocmd(git_detect_handler)
            uv.spawn("git", {
                args = { "-C", vim.fs.dirname(buf_name), "rev-parse" },
                env = nil,
                cwd = nil,
                uid = nil,
                gid = nil,
                verbatim = false,
                detached = false,
                hide = false,
                stdio = nil,
                -- stdio = { nil, nil, nil },
            }, function(exit_code)
                if exit_code == 0 then
                    vim.schedule(function()
                        api.nvim_exec_autocmds("User", { pattern = "GitLazyLoaded" })
                    end)
                end
            end)
        end,
    })
end

function M.boot()
    local install_path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

    if not uv.fs_stat(install_path) then
        echo("  Installing lazy.nvim and plugins ...")

        vim.system({ "git", "clone", "--filter=blob:none", "--branch=stable",
            "https://github.com/folke/lazy.nvim.git", install_path }, nil, function(out)
            vim.schedule(function()
                if out.code == 0 then
                    echo(" lazy.nvim installed successfully!. Loading plugins ...")
                    do_boot(install_path)
                else
                    echo("Error: Unable to install lazy.nvim and plugins", { err = true })
                end
            end)
        end)
    else
        do_boot(install_path)
    end
end

return M
