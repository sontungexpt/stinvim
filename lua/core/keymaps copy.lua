local vim, pairs = vim, pairs
local api, keymap_set = vim.api, vim.keymap.set
local autocmd = api.nvim_create_autocmd

local M = {}

local group = api.nvim_create_augroup("__core_keymap__", { clear = true })

--- Map a key to a command or callback with optional options.
---
--- `opts` supports:
--- - `string`: Mapping description (`desc`).
--- - `table`: Custom `vim.keymap.set.Opts`, overriding defaults.
--- - `boolean`: Expression mapping (`expr`).
---
--- Default options: `noremap = true`, `silent = true`, `nowait = true`.
---
--- @param mode string|string[] Mode(s) in which the mapping is active.
--- @param key string Key or key sequence to map.
--- @param map_to string|function Command or callback executed by the mapping.
--- @param opts? string|boolean|vim.keymap.set.Opts Mapping description, expression flag, or custom options.
--- @return nil
local set = function(mode, key, map_to, opts)
    local options = { noremap = true, silent = true, nowait = true }
    local opts_type = type(opts)

    if opts_type == "string" then
        options.desc = opts
    elseif opts_type == "table" then
        for k, v in pairs(opts) do
            options[k] = v
        end
    elseif opts_type == "boolean" then
        options.expr = opts
    end

    keymap_set(mode, key, map_to, options)
end
M.set = set

--- Require a module and return it, or nil if the module could not be loaded.
--- @param name string The name of the module to load.
--- @return table|nil The loaded module, or nil if the module could not be loaded.
local required = function (name)
    return require("utils").safe_require(name)
end

M.setup = function()
    vim.schedule(function()
        -- Remap for dealing with word wrap
        set({ "n", "x" }, "k", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', true)
        set({ "n", "x" }, "j", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', true)
        set({ "n", "v" }, "<Up>", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', true)
        set({ "n", "v" }, "<Down>", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', true)

        -- When you press i, automatically indent to the appropriate position
        -- map("n", "i", [[strlen(getline('.')) == 0 ? '_cc' : 'i']], 7)
        set("n", "i", function()
            local bufnr = api.nvim_get_current_buf()
            local opts = { buf = bufnr }
            if not api.nvim_get_option_value("buftype", opts) and api.nvim_get_current_line() == "" then
                local modified = api.nvim_get_option_value("modified", opts)
                api.nvim_input(api.nvim_replace_termcodes("_cc", true, true, true))
                if not modified then
                    vim.defer_fn(function()
                        if api.nvim_buf_is_valid(bufnr) then
                            api.nvim_set_option_value("modified", false, opts)
                        end
                    end, 1)
                end
            else
                api.nvim_command("startinsert")
            end
        end)

        -- Delete empty lines without writing to registers
        set("n", "dd", [[match(getline('.'), '^\\s*$') != -1 ? '"_dd' : "dd"]], true)
        set("n", "dx", "x")

        -- Delete empty lines without writing to registers
        set("n", "x", [[col('.') == 1 && match(getline('.'), '^\\s*$') != -1 ? '"_dd$' : '"_x']], true)
        set("n", "X", [[col('.') == 1 && match(getline('.'), '^\\s*$') != -1 ? '"_dd$' : '"_X']], true)

        -- -- inspect colors
        -- map("n", "<M-C>", "<cmd>Inspect<cr>")

        set("x", "P", "p")
        set("x", "p", 'p:let @+=@0<CR>:let @"=@0<CR>')

        -- Indent lines with tab in visual mode
        set("x", "<Tab>", ">gv|")
        set("x", "<S-Tab>", "<gv")
        set("n", "<Tab>", ">>_")
        set("n", "<S-Tab>", "<<_")

        set({ "i" }, "jk", "<esc>")

        -- Better escape by jj
        do
            local waiting = false
            local first_pressed_time = 0
            local modified = false
            set({ "c", "t" }, "j", function()
                local mode = api.nvim_get_mode().mode
                local now = vim.uv.now()
                if not waiting then
                    waiting = true
                    first_pressed_time = now
                elseif now - first_pressed_time < vim.o.timeoutlen then -- waiting
                    waiting = false
                    if mode == "c" then
                        api.nvim_input("<esc>")
                        return ""
                    elseif mode == "t" then
                        return [[<bs><C-\><C-n>]]
                    end
                    api.nvim_feedkeys(api.nvim_replace_termcodes("<bs><esc>", true, true, true), "n", false)
                    if not modified then
                        vim.defer_fn(function() api.nvim_set_option_value("modified", false, { buf = 0 }) end, 1)
                    end
                    return ""
                else                     -- waiting
                    first_pressed_time = now -- new waiting
                end

                if mode == "c" then
                    api.nvim_feedkeys("j", "n", true)
                    return ""
                end

                modified = api.nvim_get_option_value("modified", { buf = 0 })
                return "j"
            end, true)
        end

        --Save file as the traditional way
        set({ "n", "i", "v", "c" }, "<C-s>", "<cmd>w<cr>")

        --ctrl a to selected all text in file
        set({ "n", "i", "v" }, "<C-a>", "<cmd>normal! ggVG<cr>")

        --The arrow keys in the insert mode
        set("i", "<C-j>", "<Down>", { remap = true })
        set("i", "<C-k>", "<Up>", { remap = true })
        set("i", "<C-h>", "<Left>", { remap = true })
        set("i", "<C-l>", "<Right>", { remap = true })

        --Change the buffer
        set("n", "]b", "<cmd>bnext<cr>")
        set("n", "[b", "<cmd>bNext<cr>")

        --Go to the current path
        set({ "n", "v" }, "cd", "<cmd>cd %:p:h<cr>:pwd<cr>", { silent = false })

        --Close Buffer
        set({ "n", "v" }, "Q", function()
            local buf = api.nvim_get_current_buf()
            if api.nvim_buf_is_valid(buf) and api.nvim_get_option_value("modified", { buf = buf }) then
                require("utils.notify").warn("Buffer is modified, please save it first.")
            else
                api.nvim_buf_delete(buf, {})
            end
        end)

        --Clean searching
        set({ "n", "v" }, "C", "<cmd>noh<cr>:set ignorecase<cr>")


        --Resize Buffer
        set("n", "<A-l>", function()
            require("smart-resizing").increase("width") end)
        set("n", "<A-h>", function() require("smart-resizing").decrease("width") end)

        set("n", "<A-j>", function() require("smart-resizing").increase("height") end)
        set("n", "<A-k>", function() require("smart-resizing").decrease("height") end)

        --Make all windows (almost) equally high and wide
        set("n", "=", "<C-W>=")

        --Change the layout to horizontal
        set("n", "gv", "<C-w>t<C-w>H", "Change the layout to vertical")

        --Change the layout to vertical
        set("n", "gs", "<C-w>t<C-w>K", "Change the layout to horizontally")

        -- Split horizontally
        set("n", "<A-s>", "<cmd>split<CR>")

        -- Split vertically
        set("n", "<A-v>", "<cmd>vsplit<CR>")

        --Move between windows
        set("n", "<C-h>", "<C-w>h")
        set("n", "<C-j>", "<C-w>j")
        set("n", "<C-k>", "<C-w>k")
        set("n", "<C-l>", "<C-w>l")

        --Swap up one row
        set("n", "<A-Up>", "<cmd>m .-2<CR>==")
        set("v", "<A-Up>", "<cmd>m '<-2<CR>gv=gv")

        --Swap down one row
        set("n", "<A-Down>", "<cmd>m .+1<CR>==")
        set("v", "<A-Down>", "<cmd>m '>+1<CR>gv=gv")

        set({ "n", "x" }, "<leader>b", "<cmd>ConformFormat<cr>", "Conform format")

        ------------------------------ url-open ------------------------------
        -- map({ "n", "x" }, "gx", "<cmd>URLOpenUnderCursor<cr>", "Open URL under cursor")

        ------------------------------ nvimtree ------------------------------
        -- map({ "n", "i", "x", "c" }, "<C-b>", function()
        --     local filetype = api.nvim_get_option_value("filetype", { buf = 0 })
        --     -- local buftype = api.nvim_buf_get_option(0, "buftype")
        --     if vim.tbl_contains({ "TelescopePrompt", "lazy", "mason" }, filetype) then
        --         vim.cmd.normal { "<C-b>", bang = true }
        --     else
        --         pcall(api.nvim_command, "NvimTreeToggle")
        --     end
        -- end)

        --     ------------------------------ Telescope ------------------------------
        --     map({ "n", "i", "x" }, "<C-p>", "<cmd>Telescope find_files<cr>")
        --     map("n", "<leader>fb", "<cmd>Telescope buffers<cr>")
        --     map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>")
        --
        --     map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", "Telescope find string")
        --     map("n", "<C-f>", "<cmd>Telescope live_grep<cr>", "Telescope find string")
        --     map("n", "<leader>fw", "<cmd>Telescope grep_string<cr>", "Find word under cursor")

        --     ------------------------------ Todo-comments ------------------------------
        --     map("n", "<Leader>ft", "<cmd>TodoTelescope<cr>", "Telescope find todo comments")
        --
        --     map("n", "<leader>fd", "<cmd>Telescope diagnostics<cr>")
        --     map("n", "<leader>fc", "<cmd>Telescope command_history<cr>", "Find command history")

        --     ------------------------------ Todo-comments ------------------------------
        --     map("n", "<Leader>ft", "<cmd>TodoTelescope<cr>", "Find todo comments")
        --
        ------------------------------ Git conflict ------------------------------
        set("n", "<Leader>qfc", "<cmd>GitConflictListQf<cr>", "Git conflict quickfix")

        set("n", "[t", function()
            required("todo-comments").jump_prev()
        end, "Todo comment prev")

        set("n", "]t", function()
            required("todo-comments").jump_next()
        end, "Todo comment next")

        set("n", "[T", function()
            required("todo-comments").jump_prev { keywords = { "ERROR", "WARNING" } }
        end, "Todo comment prev error or warning")

        set("n", "]T", function()
            required("todo-comments").jump_next { keywords = { "ERROR", "WARNING" } }
        end, "Todo comment next error or warning")

        ------------------------------ ccc ------------------------------
        set({ "n", "i" }, "<A-c>", "<cmd>CccPick<cr>", "Color picker")

        ------------------------------ ufo ------------------------------
        set("n", "zR", "<cmd>lua require('ufo').openAllFolds()<CR>", "Open all folds")
        set("n", "zr", "<cmd>lua require('ufo').openFoldsExceptKinds()<CR>", "Open folds except kind")
        set("n", "zM", "<cmd>lua require('ufo').closeAllFolds()<CR>", "Close all folds")
        set("n", "zm", "<cmd>lua require('ufo').closeFoldsWith()<CR>", "Close folds with kind")

        ------------------------------ Bufferline ------------------------------
        -- map("n", "<Space>", "<Cmd>exe 'BufferLineGoToBuffer ' . v:count1<CR>")

        ------------------------------ Markdown preview ------------------------------
        -- map("n", "<Leader>pm", "<cmd>MarkdownPreviewToggle<CR>", "Toggle markdown preview")


        --------------------------------------- dap ---------------------------------------
        set("n", "<leader>du", function()
            required("dapui").toggle()
        end, "Dapui toggle")
        set("n", "<leader>db", function()
            required("dap").toggle_breakpoint()
        end, "Dap toggle breakpoint")
        set("n", "<leader>di", function()
            required("dap").step_into()
        end, "Dap step into")
        set("n", "<leader>do", function()
            required("dap").step_over()
        end, "Dap step over")
        set("n", "<leader>dc", function()
            required("dap").continue()
        end, "Dap continue or start debugging")
        set("n", "<leader>dd", function()
            required("dap").disconnect()
        end, "Dap disconnect from debugger")
        set("n", "<F11>", function()
            required("dap").step_into()
        end, "Dap step into")
        set("n", "<F12>", function()
            required("dap").step_over()
        end, "Dap step over")
        set("n", "<F5>", function()
            required("dap").continue()
        end, "Dap continue or start debugging")
        set("n", "<F4>", function()
            required("dap").disconnect()
        end, "Dap disconnect from debugger")
        set("n", "<Leader>dr", function()
            required("dap").repl.open()
        end, "Dap open REPL")
        set("n", "<Leader>dl", function()
            required("dap").run_last()
        end, "Dap run last")

        set({ "n", "v" }, "<Leader>dh", function()
            required("dap.ui.widgets").hover()
        end, "Dap hover widgets")
        set({ "n", "v" }, "<Leader>dp", function()
            required("dap.ui.widgets").preview()
        end, "Dap preview widgets")
        set("n", "<Leader>df", function()
            required("dap.ui.widgets").centered_float(required("dap.ui.widgets").frames)
        end, "Dap frames")
        set("n", "<Leader>ds", function()
            required("dap.ui.widgets").centered_float(required("dap.ui.widgets").scopes)
        end, "Dap scopes")

        ------------------------------ Neocodeium ------------------------------
        set("i", "<A-Tab>", function() require("neocodeium").accept() end, "Accept AI suggestion")

        ------------------------------ Snacks ------------------------------
        M.snacks()
    end)
end

autocmd("LspAttach", {
    group = group,
    desc = "LSP Keymaps",
    callback = function(args)
        local lsp = vim.lsp
        local client = lsp.get_client_by_id(args.data.client_id)
        if not client then
            return
        end

        local bufnr = args.buf
        local function buf_map(mode, lhs, rhs, desc)
            set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end

        -- LSP navigation
        buf_map("n", "gd", lsp.buf.definition, "Goto Definition")
        buf_map("n", "gD", lsp.buf.declaration, "Goto Declaration")
        buf_map("n", "gr", lsp.buf.references, "References")
        buf_map("n", "gI", lsp.buf.implementation, "Goto Implementation")
        buf_map("n", "gy", lsp.buf.type_definition, "Goto Type Definition")

        -- LSP actions
        buf_map("n", "K", lsp.buf.hover, "Hover")
        buf_map("n", "gK", lsp.buf.signature_help, "Signature Help")
        buf_map("n", "<leader>ca", lsp.buf.code_action, "Code Action")
        buf_map("n", "<leader>cr", lsp.buf.rename, "Rename")
        buf_map("n", "<leader>ss", lsp.buf.document_symbol, "Document Symbols")

        -- Diagnostics
        buf_map("n", "<leader>cd", vim.diagnostic.open_float, "Line Diagnostics")

        buf_map("n", "]d", function()
            vim.diagnostic.jump({ count = 1 })
        end, "Diagnostic: Next")
        buf_map("n", "[d", function()
            vim.diagnostic.jump({ count = -1 })
        end, "Diagnostic: Previous")

        buf_map("n", "]e", function()
            vim.diagnostic.jump({
                count = 1,
                severity = vim.diagnostic.severity.ERROR,
            })
        end, "Diagnostic: Next Error")
        buf_map("n", "[e", function()
            vim.diagnostic.jump({
                count = -1,
                severity = vim.diagnostic.severity.ERROR,
            })
        end, "Diagnostic: Previous Error")


        buf_map("n", "]w", function()
            vim.diagnostic.jump({
                count = 1,
                severity = vim.diagnostic.severity.WARN,
            })
        end, "Diagnostic: Next Warning")
        buf_map("n", "[w", function()
            vim.diagnostic.jump({
                count = -1,
                severity = vim.diagnostic.severity.WARN,
            })
        end, "Diagnostic: Previous Warning")

        -- JDTLS
        if vim.bo[bufnr].filetype ~= "java" or client.name ~= "jdtls" then
            return
        end

        local ok, jdtls = pcall(require, "jdtls")
        if not ok then
            return
        end

        buf_map("n", "<leader>co", jdtls.organize_imports, "Organize Imports")

        -- Rarely used so just comment for now
        -- buf_map("v", "<leader>ev", jdtls.extract_variable, "Extract Variable")
        -- buf_map("v", "<leader>ec", jdtls.extract_constant, "Extract Constant")
        -- buf_map("v", "<leader>em", jdtls.extract_method, "Extract Method")
        -- buf_map("n", "<leader>tc", jdtls.test_class, "Test Class")
        -- buf_map("n", "<leader>tm", jdtls.test_nearest_method, "Test Nearest Method")
        -- buf_map("n", "<leader>up", jdtls.update_project_config, "Update Project Config")
    end,
})

autocmd({ "BufWinEnter", "CmdwinEnter" }, {
    group = group,
    desc = "Make q close special buffers",
    callback = function(args)
        local buftype = vim.api.nvim_get_option_value("buftype", { buf = args.buf })
        if args.event == "BufWinEnter" and not vim.list_contains({ "help", "nofile", "quickfix" }, buftype) then return end
        require("utils.mapper").map("n", "q", "<cmd>close<cr>", { buffer = args.buf })
    end,
})



M.snacks = function()
    local map = require("utils.mapper").map

    -- Picker
    map("n", "<leader>f", function() require("snacks").picker.files() end, "Find files")
    map("n", "<leader>g", function() require("snacks").picker.grep() end, "Grep")
    map("n", "<leader>b", function() require("snacks").picker.buffers() end, "Buffers")
    map("n", "<leader>h", function() require("snacks").picker.help() end, "Help")
    map("n", "<leader>c", function() require("snacks").picker.commands() end, "Commands")

    -- Explorer
    map("n", "<C-b>", function() require("snacks").explorer() end, "File explorer")

    -- Notifier
    map("n", "<leader>n", function() require("snacks").notifier.show_history() end, "Notification history")

    -- Lazygit
    map("n", "<leader>gg", function() require("snacks").lazygit() end, "Lazygit")

    -- Terminal
    map({ "n", "t" }, "<C-t>", function() require("snacks").terminal() end, "Toggle terminal")
end

M.gitsigns = function(bufnr)
    local map = require("utils.mapper").map
    local gs = require("gitsigns")

    local buf_map = function(mode, key, map_to, desc) map(mode, key, map_to, { buffer = bufnr, desc = desc }) end

    -- Navigation
    buf_map("n", "]g", function()
        if vim.wo.diff then
            vim.cmd.normal { "]g", bang = true }
        else
            gs.nav_hunk("next")
        end
    end, "Gitsigns next hunk")
    buf_map("n", "[g", function()
        if vim.wo.diff then
            vim.cmd.normal { "[g", bang = true }
        else
            gs.nav_hunk("prev")
        end
    end, "Gitsigns previous hunk")

    buf_map("n", "<leader>gs", gs.stage_hunk, "Gitsigns stage hunk")
    buf_map("x", "<leader>gs", function() gs.stage_hunk { vim.fn.line("."), vim.fn.line("v") } end, "Gitsigns stage hunk")
    buf_map("n", "<leader>gr", gs.reset_hunk, "Reset hunk")
    buf_map("x", "<leader>gr", function() gs.reset_hunk { vim.fn.line("."), vim.fn.line("v") } end, "Gitsigns reset hunk")
    buf_map("n", "<leader>gu", gs.undo_stage_hunk, "Gitsigns undo stage hunk")
    buf_map("n", "<leader>gR", gs.reset_buffer, "Gitsigns reset buffer")
    buf_map("n", "<leader>gp", gs.preview_hunk, "Gitsigns preview hunk")
    buf_map("n", "<leader>gb", gs.toggle_current_line_blame, "Gitsigns blame line")
    buf_map("n", "<leader>gd", gs.diffthis, "Gitsigns diff this")
    buf_map("n", "<leader>gD", function() gs.diffthis("~") end, "Gitsigns diff this")
end


return M
