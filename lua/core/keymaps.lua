local vim = vim
local api = vim.api
local autocmd, augroup = api.nvim_create_autocmd, api.nvim_create_augroup

local M = {}

local group = augroup("__keymap__", { clear = true })

M.setup = vim.schedule_wrap(function()
    local map = require("utils.mapper").map
    local load_mod = require("utils.init").load_mod

    -- Remap for dealing with word wrap
    map({ "n", "x" }, "k", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', 7)
    map({ "n", "x" }, "j", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', 7)
    map({ "n", "v" }, "<Up>", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', 7)
    map({ "n", "v" }, "<Down>", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', 7)

    -- When you press i, automatically indent to the appropriate position
    -- map("n", "i", [[strlen(getline('.')) == 0 ? '_cc' : 'i']], 7)
    map("n", "i", function()
        if not api.nvim_get_option_value("buftype", { buf = 0 }) and api.nvim_get_current_line() == "" then
            local modified = api.nvim_get_option_value("modified", { buf = 0 })
            api.nvim_input(api.nvim_replace_termcodes("_cc", true, true, true))
            if not modified then vim.defer_fn(function() api.nvim_set_option_value("modified", false, { buf = 0 }) end, 1) end
        else
            api.nvim_command("startinsert")
        end
    end)

    -- Delete empty lines without writing to registers
    map("n", "dd", [[match(getline('.'), '^\\s*$') != -1 ? '"_dd' : "dd"]], 7)
    map("n", "dx", "x")

    -- inspect colors
    map("n", "<M-C>", "<cmd>Inspect<cr>")

    -- Delete empty lines without writing to registers
    map("n", "x", [[col('.') == 1 && match(getline('.'), '^\\s*$') != -1 ? '"_dd$' : '"_x']], 7)
    map("n", "X", [[col('.') == 1 && match(getline('.'), '^\\s*$') != -1 ? '"_dd$' : '"_X']], 7)

    map("x", "P", "p")
    map("x", "p", 'p:let @+=@0<CR>:let @"=@0<CR>')

    -- Indent lines with tab in visual mode
    map("x", "<Tab>", ">gv|")
    map("x", "<S-Tab>", "<gv")
    map("n", "<Tab>", ">>_")
    map("n", "<S-Tab>", "<<_")

    map({ "i" }, "jk", "<esc>")

    -- Better escape by jj
    do
        local waiting = false
        local first_pressed_time = 0
        local modified = false
        map({ "c", "t" }, "j", function()
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
            else                         -- waiting
                first_pressed_time = now -- new waiting
            end

            if mode == "c" then
                api.nvim_feedkeys("j", "n", true)
                return ""
            end

            modified = api.nvim_get_option_value("modified", { buf = 0 })
            return "j"
        end, 7)
    end

    --Save file as the traditional way
    map({ "n", "i", "v", "c" }, "<C-s>", "<cmd>w<cr>", 2)

    --ctrl a to selected all text in file
    map({ "n", "i", "v" }, "<C-a>", "<cmd>normal! ggVG<cr>")

    --The arrow keys in the insert mode
    map("i", "<C-j>", "<Down>")
    map("i", "<C-k>", "<Up>")
    map("i", "<C-h>", "<Left>")
    map("i", "<C-l>", "<Right>")

    --Change the buffer
    map("n", "]b", "<cmd>bnext<cr>")
    map("n", "[b", "<cmd>bNext<cr>")

    --Go to the current path
    map({ "n", "v" }, "cd", "<cmd>cd %:p:h<cr>:pwd<cr>", 3)

    --Close Buffer
    map({ "n", "v" }, "Q", function()
        local buf = api.nvim_get_current_buf()
        if api.nvim_buf_is_valid(buf) and api.nvim_get_option_value("modified", { buf = buf }) then
            require("utils.notify").warn("Buffer is modified, please save it first.")
        else
            api.nvim_buf_delete(buf, {})
        end
    end)

    --Clean searching
    map({ "n", "v" }, "C", "<cmd>noh<cr>:set ignorecase<cr>")

    --Resize Buffer
    map("n", "<A-h>", function() require("smart-resizing").adjust_current_win_width(1, 2) end)
    map("n", "<A-l>", function() require("smart-resizing").adjust_current_win_width(1, 1) end)

    map("n", "<A-j>", function() require("smart-resizing").adjust_current_win_height(1, 2) end)
    map("n", "<A-k>", function() require("smart-resizing").adjust_current_win_height(1, 1) end)

    --Make all windows (almost) equally high and wide
    map("n", "=", "<C-W>=")

    --Change the layout to horizontal
    map("n", "gv", "<C-w>t<C-w>H", "Change the layout to vertical")

    --Change the layout to vertical
    map("n", "gh", "<C-w>t<C-w>K", "Change the layout to horizontally")

    -- Split horizontally
    map("n", "<A-s>", "<cmd>split<CR>")

    -- Split vertically
    map("n", "<A-v>", "<cmd>vsplit<CR>")

    --Move between windows
    map("n", "<C-h>", "<C-w>h")
    map("n", "<C-j>", "<C-w>j")
    map("n", "<C-k>", "<C-w>k")
    map("n", "<C-l>", "<C-w>l")

    --Swap up one row
    map("n", "<A-Up>", "<cmd>m .-2<CR>==")
    map("v", "<A-Up>", "<cmd>m '<-2<CR>gv=gv")

    --Swap down one row
    map("n", "<A-Down>", "<cmd>m .+1<CR>==")
    map("v", "<A-Down>", "<cmd>m '>+1<CR>gv=gv")

    map({ "n", "x" }, "<leader>b", "<cmd>ConformFormat<cr>", "Conform format")

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

    ------------------------------ Telescope ------------------------------
    map({ "n", "i", "x" }, "<C-p>", "<cmd>Telescope find_files<cr>")
    map("n", "<leader>fb", "<cmd>Telescope buffers<cr>")
    map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>")

    map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", "Telescope find string")
    map("n", "<C-f>", "<cmd>Telescope live_grep<cr>", "Telescope find string")
    map("n", "<leader>fw", "<cmd>Telescope grep_string<cr>", "Find word under cursor")

    ------------------------------ Todo-comments ------------------------------
    map("n", "<Leader>ft", "<cmd>TodoTelescope<cr>", "Telescope find todo comments")

    map("n", "<leader>fd", "<cmd>Telescope diagnostics<cr>")
    map("n", "<leader>fc", "<cmd>Telescope command_history<cr>", "Find command history")

    ------------------------------ Todo-comments ------------------------------
    map("n", "<Leader>ft", "<cmd>TodoTelescope<cr>", "Find todo comments")

    ------------------------------ Git conflict ------------------------------
    map("n", "<Leader>qfc", "<cmd>GitConflictListQf<cr>", "Git conflict quickfix")

    map("n", "[t", function()
        load_mod("todo-comments", function(todo_comments) todo_comments.jump_prev() end)
    end, "Todo comment prev")

    map("n", "]t", function()
        load_mod("todo-comments", function(todo_comments) todo_comments.jump_next() end)
    end, "Todo comment next")

    map("n", "[T", function()
        load_mod("todo-comments",
            function(todo_comments) todo_comments.jump_prev { keywords = { "ERROR", "WARNING" } } end)
    end, "Todo comment prev error or warning")

    map("n", "]T", function()
        load_mod("todo-comments",
            function(todo_comments) todo_comments.jump_next { keywords = { "ERROR", "WARNING" } } end)
    end, "Todo comment next error or warning")

    ------------------------------ ccc ------------------------------
    map({ "n", "i" }, "<A-c>", "<cmd>CccPick<cr>", "Color picker")

    ------------------------------ ufo ------------------------------
    map("n", "zR", "<cmd>lua require('ufo').openAllFolds()<CR>", "Open all folds")
    map("n", "zr", "<cmd>lua require('ufo').openFoldsExceptKinds()<CR>", "Open folds except kind")
    map("n", "zM", "<cmd>lua require('ufo').closeAllFolds()<CR>", "Close all folds")
    map("n", "zm", "<cmd>lua require('ufo').closeFoldsWith()<CR>", "Close folds with kind")

    ------------------------------ Bufferline ------------------------------
    -- map("n", "<Space>", "<Cmd>exe 'BufferLineGoToBuffer ' . v:count1<CR>")

    ------------------------------ Markdown preview ------------------------------
    map("n", "<Leader>pm", "<cmd>MarkdownPreviewToggle<CR>", "Toggle markdown preview")


    --------------------------------------- dap ---------------------------------------
    map("n", "<leader>du", function()
        load_mod("dapui", function(dapui) dapui.toggle() end)
    end, "Dapui toggle")
    map("n", "<leader>db", function()
        load_mod("dap", function(dap) dap.toggle_breakpoint() end)
    end, "Dap toggle breakpoint")
    map("n", "<leader>di", function()
        load_mod("dap", function(dap) dap.step_into() end)
    end, "Dap step into")
    map("n", "<leader>do", function()
        load_mod("dap", function(dap) dap.step_over() end)
    end, "Dap step over")
    map("n", "<leader>dc", function()
        load_mod("dap", function(dap) dap.continue() end)
    end, "Dap continue or start debugging")
    map("n", "<leader>dd", function()
        load_mod("dap", function(dap)
            dap.disconnect()
            dap.close()
        end)
    end, "Dap disconnect from debugger")
    map("n", "<F11>", function()
        load_mod("dap", function(dap) dap.step_into() end)
    end, "Dap step into")
    map("n", "<F12>", function()
        load_mod("dap", function(dap) dap.step_over() end)
    end, "Dap step over")
    map("n", "<F5>", function()
        load_mod("dap", function(dap) dap.continue() end)
    end, "Dap continue or start debugging")
    map("n", "<F4>", function()
        load_mod("dap", function(dap)
            dap.disconnect()
            dap.close()
        end)
    end, "Dap disconnect from debugger")
    map("n", "<Leader>dr", function()
        load_mod("dap", function(dap) dap.repl.open() end)
    end, "Dap open REPL")
    map("n", "<Leader>dl", function()
        load_mod("dap", function(dap) dap.run_last() end)
    end, "Dap run last")

    map({ "n", "v" }, "<Leader>dh", function()
        load_mod("dap.ui.widgets", function(widgets) widgets.hover() end)
    end, "Dap hover widgets")
    map({ "n", "v" }, "<Leader>dp", function()
        load_mod("dap.ui.widgets", function(widgets) widgets.preview() end)
    end, "Dap preview widgets")
    map("n", "<Leader>df", function()
        load_mod("dap.ui.widgets", function(widgets) widgets.centered_float(widgets.frames) end)
    end, "Dap frames")
    map("n", "<Leader>ds", function()
        load_mod("dap.ui.widgets", function(widgets) widgets.centered_float(widgets.scopes) end)
    end, "Dap scopes")

    ------------------------------ MasonScout ------------------------------
    map("n", "<leader>ms", function()
        load_mod("mason-scout", function(ms)
            ms.open_ui()
        end)
    end, "MasonScout: open suggestion UI")

    ------------------------------ Snacks ------------------------------
    M.snacks()
end)

autocmd("LspAttach", {
    group = group,
    desc = "LSP Keymaps",
    callback = function(ev)
        local map = require("utils.mapper").map
        local load_mod = require("utils").load_mod

        local buf = ev.buf
        local client = vim.lsp.get_client_by_id(ev.data.client_id)

        if not client then
            return
        end

        local function buf_map(mode, lhs, rhs, desc)
            map(mode, lhs, rhs, {
                buffer = buf,
                desc = desc,
            })
        end

        -- LSP navigation
        buf_map("n", "gd", vim.lsp.buf.definition, "Goto Definition")
        buf_map("n", "gD", vim.lsp.buf.declaration, "Goto Declaration")
        buf_map("n", "gr", vim.lsp.buf.references, "References")
        buf_map("n", "gI", vim.lsp.buf.implementation, "Goto Implementation")
        buf_map("n", "gy", vim.lsp.buf.type_definition, "Goto Type Definition")

        -- LSP actions
        buf_map("n", "K", vim.lsp.buf.hover, "Hover")
        buf_map("n", "gK", vim.lsp.buf.signature_help, "Signature Help")
        buf_map("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")
        buf_map("n", "<leader>cr", vim.lsp.buf.rename, "Rename")
        buf_map("n", "<leader>ss", vim.lsp.buf.document_symbol, "Document Symbols")

        -- Diagnostics
        buf_map("n", "<leader>cd", vim.diagnostic.open_float, "Line Diagnostics")

        buf_map("n", "[d", function()
            vim.diagnostic.jump({ count = -1 })
        end, "Previous Diagnostic")

        buf_map("n", "]d", function()
            vim.diagnostic.jump({ count = 1 })
        end, "Next Diagnostic")

        buf_map("n", "[e", function()
            vim.diagnostic.jump({
                count = -1,
                severity = vim.diagnostic.severity.ERROR,
            })
        end, "Previous Error")

        buf_map("n", "]e", function()
            vim.diagnostic.jump({
                count = 1,
                severity = vim.diagnostic.severity.ERROR,
            })
        end, "Next Error")

        buf_map("n", "[w", function()
            vim.diagnostic.jump({
                count = -1,
                severity = vim.diagnostic.severity.WARN,
            })
        end, "Previous Warning")

        buf_map("n", "]w", function()
            vim.diagnostic.jump({
                count = 1,
                severity = vim.diagnostic.severity.WARN,
            })
        end, "Next Warning")

        -- JDTLS
        if vim.bo[buf].filetype ~= "java" or client.name ~= "jdtls" then
            return
        end

        local function jdtls_map(mode, lhs, method, desc)
            buf_map(mode, lhs, function()
                load_mod("jdtls", function(jdtls)
                    jdtls[method]()
                end)
            end, desc)
        end

        jdtls_map("n", "<leader>co", "organize_imports", "Organize Imports")
        jdtls_map("v", "<leader>ev", "extract_variable", "Extract Variable")
        jdtls_map("v", "<leader>ec", "extract_constant", "Extract Constant")
        jdtls_map("v", "<leader>em", "extract_method", "Extract Method")
        jdtls_map("n", "<leader>tc", "test_class", "Test Class")
        jdtls_map("n", "<leader>tm", "test_nearest_method", "Test Nearest Method")
        jdtls_map("n", "<leader>up", "update_project_config", "Update Project Config")
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

M.blink_cmp = {
    ["<C-k>"] = { "select_prev", "fallback" },
    ["<C-j>"] = { "select_next", "fallback" },
    ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
    ["<C-e>"] = { "cancel", "fallback" },
    ["<CR>"] = { "accept", "fallback" },
    ["<Tab>"] = { "fallback" },
    ["<S-Tab>"] = { "fallback" },
}

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
