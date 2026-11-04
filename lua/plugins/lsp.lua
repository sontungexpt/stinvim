local vim = vim
local lsp, fn = vim.lsp, vim.fn
-- ---------------------------------------------------- LSP ----------------------------------------------------
-- Language Server Protocol plugins.
-- Mission: LSP configuration, server management (mason), language-specific servers, and LSP keymaps.

return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      servers = {
        -- kotlin
        { name = "kotlin_language_server" },

        -- python
        { name = "pylyzer" },

        -- go
        -- { name = "gopls" },

        -- bash
        { name = "bashls" },

        -- cpp
        { name = "clangd" },

        { name = "cmake" },

        -- zig
        { name = "zls" },

        -- web
        { name = "biome" },
        { name = "cssls" },
        { name = "eslint" },
        { name = "svelte" },
        { name = "html" },
        { name = "jsonls" },
        { name = "tailwindcss" },
        { name = "vtsls" },
        {
          name = "emmet_ls",
          config = {
            filetypes = {
              "html",
              "css",
              "sass",
              "scss",
              "less",
              "javascript",
              "typescript",
              "jsx",
              "tsx",
              "typescriptreact",
              "javascriptreact",
              "vue",
              "vue-html",
            },
          },
        },

        -- lua
        {
          name = "lua_ls",
          config = {
            settings = {
              Lua = {
                runtime = {
                  version = "LuaJIT",
                },
                diagnostics = {
                  globals = { "vim" },
                },
                workspace = {
                  library = {
                    [fn.expand("$VIMRUNTIME/lua")] = true,
                    [fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
                    [fn.stdpath("data") .. "/lazy/lazy.nvim/lua/lazy"] = true,
                    ["${3rd}/luv/library"] = true,
                  },
                  maxPreload = 100000,
                  preloadFileSize = 10000,
                },
              },
            },
          },
        },
      },
    },
    config = function(_, opts)
      local core_lsp = require("core.lsp")
      --- Diagnostic configuration
      core_lsp.setup_diagnostics()

      --- LSP handlers
      lsp.buf.signature_help({
        border = "single",
        focusable = false,
        relative = "cursor",
      })
      lsp.buf.hover({
        border = "single",
      })

      --- Base capabilities
      local capabilities = core_lsp.make_default_capabilities()
      --- Default config for all servers
      lsp.config("*", {
        capabilities = capabilities,
        on_init = function(client)
          if client:supports_method("textDocument/semanticTokens") then
            client.server_capabilities.semanticTokensProvider = nil
          end
        end,
      })

      --- Apply per-server overrides and enable servers
      -- Neovim automatically merges server config with vim.lsp.config("*", ...)
      -- so we only need to call vim.lsp.config() when there are per-server overrides.
      for _, server in ipairs(opts.servers) do
        if server.config then
          lsp.config(server.name, server.config)
        end
        lsp.enable(server.name)
      end
    end,
  },
  {
    "mfussenegger/nvim-jdtls",
    ft = "java",
  },
  {
    "mrcjkb/rustaceanvim",
    ft = "rust",
    -- rustaceanvim manages rust-analyzer itself, do NOT use mason for it
    -- See: https://github.com/mrcjkb/rustaceanvim#important
  },
  {
    "mason-org/mason.nvim",
    build = ":MasonUpdate",
    cmd = { "Mason", "MasonLog", "MasonUpdate", "MasonInstall", "MasonUninstall", "MasonUninstallAll" },
    main = "mason",
    opts = {
      ensure_installed = { "stylua", "shfmt" },
      ui = {
        border = "single",
        icons = {
          package_pending = " ",
          package_installed = " ",
          package_uninstalled = " ",
        },
      },
    },
    config = function(_, opts)
      require("mason").setup(opts)
      local mr = require("mason-registry")
      mr:on("package:install:success", function()
        vim.defer_fn(function()
          require("lazy.core.handler.event").trigger({
            event = "FileType",
            buf = vim.api.nvim_get_current_buf(),
          })
        end, 100)
      end)
    end,
  },
  {
    dir = "/home/stilux/Data/workspace/neovim-plugins/mason-scout",
    lazy = false,
    cmd = {
      "MasonScout",
    },
    opts = {} -- see Configuration section
  },
  -- {
  --   "Saecki/crates.nvim",
  --   ft = { "toml" },
  --   config = function()
  --     require("crates").setup({
  --       lsp = {
  --         enabled = true,
  --         actions = true,
  --         completion = true,
  --         hover = true,
  --       },
  --       popup = {
  --         autofocus = false,
  --       },
  --     })
  --   end,
  -- },
  -- {
  --   "akinsho/flutter-tools.nvim",
  --   ft = "dart",
  --   event = "BufReadPost */pubspec.yaml",
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --     "stevearc/dressing.nvim",
  --   },
  --   main = "flutter-tools",
  --   opts = {
  --     ui = {
  --       border = "single",
  --     },
  --     lsp = {
  --       on_attach = function(client, bufnr) end,
  --     },
  --   },
  -- },
}
