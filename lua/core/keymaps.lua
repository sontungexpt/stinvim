local vim = vim
local api, set = vim.api, vim.keymap.set
local autocmd = api.nvim_create_autocmd

local M = {}

local group = api.nvim_create_augroup("__core_keymap__", { clear = true })

-- Reusable native keymap options.
--- @type vim.keymap.set.Opts
local expr = { expr = true }
-- local nowait_expr = { expr = true, nowait = true }
-- local nowait = { nowait = true }
-- local remap = { remap = true }
-- local silent = { silent = true }

local safe_require = function(name)
    return require("utils").safe_require(name)
end

M.setup = function()
    vim.schedule(function()
        --Save file as the traditional way
        set({ "n", "i", "v", "c" }, "<C-s>", "<cmd>write<cr>", { desc = "Save file" })

        -- Remap for dealing with word wrap
        set({ "n", "x" }, "k", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', expr)
        set({ "n", "x" }, "j", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', expr)
        set({ "n", "v" }, "<Up>", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', expr)
        set({ "n", "v" }, "<Down>", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', expr)

        set("i", "<C-j>", "<Down>")
        set("i", "<C-k>", "<Up>")
        set("i", "<C-l>", "<Right>")
        set("i", "<C-h>", "<Left>")

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
        set("n", "dd", [[match(getline('.'), '^\\s*$') != -1 ? '"_dd' : "dd"]], expr)
        set("n", "dx", "x")

        -- Delete empty lines without writing to registers
        set("n", "x", [[col('.') == 1 && match(getline('.'), '^\\s*$') != -1 ? '"_dd$' : '"_x']], expr)
        set("n", "X", [[col('.') == 1 && match(getline('.'), '^\\s*$') != -1 ? '"_dd$' : '"_X']], expr)

        -- -- inspect colors
        -- map("n", "<M-C>", "<cmd>Inspect<cr>")

        -- Preserve the yank register when pasting over a Visual selection.
        set("x", "P", "P")
        -- Delete the selection into the black-hole register before pasting,
        -- preserving the previously yanked content for repeated pastes.
        set("x", "p", '"_dP')

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
                else                         -- waiting
                    first_pressed_time = now -- new waiting
                end

                if mode == "c" then
                    api.nvim_feedkeys("j", "n", true)
                    return ""
                end

                modified = api.nvim_get_option_value("modified", { buf = 0 })
                return "j"
            end, expr)
        end


        --Change the buffer
        set("n", "]b", "<cmd>bnext<cr>")
        set("n", "[b", "<cmd>bNext<cr>")

        --Go to the current path
        set({ "n", "v" }, "cd", "<cmd>cd %:p:h<cr>:pwd<cr>")

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
        set("n", "<A-l>", function() safe_require("smart-resizing").increase("width") end)
        set("n", "<A-h>", function() safe_require("smart-resizing").decrease("width") end)

        set("n", "<A-j>", function() safe_require("smart-resizing").increase("height") end)
        set("n", "<A-k>", function() safe_require("smart-resizing").decrease("height") end)

        --Make all windows (almost) equally high and wide
        set("n", "=", "<C-W>=")

        --Change the layout to horizontal
        set("n", "gv", "<C-w>t<C-w>H", { desc = "Change the layout to vertical" })
        --Change the layout to vertical
        set("n", "gs", "<C-w>t<C-w>K", { desc = "Change the layout to horizontally" })

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
        set("n", "<Leader>qfc", "<cmd>GitConflictListQf<cr>", { desc = "Git conflict quickfix" })

        --         set("n", "[t", function()
        --             safe_require("todo-comments").jump_prev()
        --         end, { desc = "Todo comment prev" })
        --
        --         set("n", "]t", function()
        --             safe_require("todo-comments").jump_next()
        --         end, { desc = "Todo comment next" })
        --
        --         set("n", "[T", function()
        --             safe_require("todo-comments").jump_prev { keywords = { "ERROR", "WARNING" } }
        --         end, { desc = "Todo comment prev error or warning" })
        --
        --         set("n", "]T", function()
        --             safe_require("todo-comments").jump_next { keywords = { "ERROR", "WARNING" } }
        --         end, { desc = "Todo comment next error or warning" })

        ------------------------------ ccc ------------------------------
        set({ "n", "i" }, "<A-c>", "<cmd>CccPick<cr>", { desc = "Color picker" })

        ------------------------------ ufo ------------------------------
        -- set("n", "zR", "<cmd>lua require('ufo').openAllFolds()<CR>", { desc = "Open all folds" })
        -- set("n", "zr", "<cmd>lua require('ufo').openFoldsExceptKinds()<CR>", { desc = "Open folds except kind" })
        -- set("n", "zM", "<cmd>lua require('ufo').closeAllFolds()<CR>", { desc = "Close all folds" })
        -- set("n", "zm", "<cmd>lua require('ufo').closeFoldsWith()<CR>", { desc = "Close folds with kind" })

        ------------------------------ Bufferline ------------------------------
        -- map("n", "<Space>", "<Cmd>exe 'BufferLineGoToBuffer ' . v:count1<CR>")

        ------------------------------ Markdown preview ------------------------------
        -- map("n", "<Leader>pm", "<cmd>MarkdownPreviewToggle<CR>", "Toggle markdown preview")


        --------------------------------------- dap ---------------------------------------
        set("n", "<leader>du", function() safe_require("dapui").toggle() end, { desc = "Dapui toggle" })
        set("n", "<leader>db", function() safe_require("dap").toggle_breakpoint() end, { desc = "Dap toggle breakpoint" })
        set("n", "<leader>di", function() safe_require("dap").step_into() end, { desc = "Dap step into" })
        set("n", "<leader>do", function() safe_require("dap").step_over() end, { desc = "Dap step over" })
        set("n", "<leader>dc", function() safe_require("dap").continue() end,
            { desc = "Dap continue or start debugging" })
        set("n", "<leader>dd", function() safe_require("dap").disconnect() end, { desc = "Dap disconnect from debugger" })
        set("n", "<F11>", function() safe_require("dap").step_into() end, { desc = "Dap step into" })
        set("n", "<F12>", function() safe_require("dap").step_over() end, { desc = "Dap step over" })
        set("n", "<F5>", function() safe_require("dap").continue() end, { desc = "Dap continue or start debugging" })
        set("n", "<F4>", function() safe_require("dap").disconnect() end, { desc = "Dap disconnect from debugger" })
        set("n", "<Leader>dr", function() safe_require("dap").repl.open() end, { desc = "Dap open REPL" })
        set("n", "<Leader>dl", function() safe_require("dap").run_last() end, { desc = "Dap run last" })
        set({ "n", "v" }, "<Leader>dh",
            function() safe_require("dap.ui.widgets").hover() end,
            { desc = "Dap hover widgets" }
        )
        set({ "n", "v" }, "<Leader>dp",
            function() safe_require("dap.ui.widgets").preview() end,
            { desc = "Dap preview widgets" }
        )
        set("n", "<Leader>df",
            function() safe_require("dap.ui.widgets").centered_float(safe_require("dap.ui.widgets").frames) end,
            { desc = "Dap frames" }
        )
        set("n", "<Leader>ds",
            function() safe_require("dap.ui.widgets").centered_float(safe_require("dap.ui.widgets").scopes) end,
            { desc = "Dap scopes" }
        )

        ------------------------------ Neocodeium ------------------------------
        set("i", "<A-Tab>", function() safe_require("neocodeium").accept() end, { desc = "Accept AI suggestion" })

        ------------------------------ Snacks ------------------------------
        --     -- Picker
        --     map("n", "<leader>f", function() safe_require("snacks").picker.files() end, { desc = "Find files" })
        --     map("n", "<leader>g", function() safe_require("snacks").picker.grep() end, { desc = "Grep" })
        --     map("n", "<leader>b", function() safe_require("snacks").picker.buffers() end, { desc = "Buffers" })
        --     map("n", "<leader>h", function() safe_require("snacks").picker.help() end, { desc = "Help" })
        --     map("n", "<leader>c", function() safe_require("snacks").picker.commands() end, { desc = "Commands" })
        --

        -- Explorer
        set("n", "<C-b>", function() safe_require("snacks").explorer() end, { desc = "File explorer" })
        -- Terminal
        set({ "n", "t" }, "<C-t>", function() safe_require("snacks").terminal() end, { desc = "Toggle terminal" })
        --
        --     -- Notifier
        --     map("n", "<leader>n", function() safe_require("snacks").notifier.show_history() end, { desc = "Notification history" })
        --
        --     -- Lazygit
        --     map("n", "<leader>gg", function() safe_require("snacks").lazygit() end, { desc = "Lazygit" })
        --
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
        if args.event == "BufWinEnter" and not vim.list_contains({ "help", "nofile", "quickfix" }, vim.bo[args.buf].buftype) then
            return
        end
        set("n", "q", "<cmd>close<cr>", { buffer = args.buf })
    end,
})

M.gitsigns = function(bufnr)
    local buf_map = function(mode, key, map_to, desc)
        set(mode, key, map_to, { buffer = bufnr, desc = desc })
    end

    -- Navigation
    buf_map("n", "]g", function()
        if vim.wo.diff then
            vim.cmd.normal { "]g", bang = true }
        else
            safe_require("gitsigns").nav_hunk("next")
        end
    end, "Gitsigns next hunk")
    buf_map("n", "[g", function()
        if vim.wo.diff then
            vim.cmd.normal { "[g", bang = true }
        else
            safe_require("gitsigns").nav_hunk("prev")
        end
    end, "Gitsigns previous hunk")

    buf_map("n", "<leader>gs", function() safe_require("gitsigns").stage_hunk() end, "Gitsigns stage hunk")
    buf_map("x", "<leader>gs", function() safe_require("gitsigns").stage_hunk { vim.fn.line("."), vim.fn.line("v") } end,
        "Gitsigns stage hunk")
    buf_map("n", "<leader>gr", function() safe_require("gitsigns").reset_hunk() end, "Reset hunk")
    buf_map("x", "<leader>gr", function() safe_require("gitsigns").reset_hunk { vim.fn.line("."), vim.fn.line("v") } end,
        "Gitsigns reset hunk")
    buf_map("n", "<leader>gu", function() safe_require("gitsigns").undo_stage_hunk() end, "Gitsigns undo stage hunk")
    buf_map("n", "<leader>gR", function() safe_require("gitsigns").reset_buffer() end, "Gitsigns reset buffer")
    buf_map("n", "<leader>gp", function() safe_require("gitsigns").preview_hunk() end, "Gitsigns preview hunk")
    buf_map("n", "<leader>gb", function() safe_require("gitsigns").toggle_current_line_blame() end, "Gitsigns blame line")
    buf_map("n", "<leader>gd", function() safe_require("gitsigns").diffthis() end, "Gitsigns diff this")
    buf_map("n", "<leader>gD", function() safe_require("gitsigns").diffthis("~") end, "Gitsigns diff this")
end


return M
