local vim = vim

-- ---------------------------------------------------- Syntax ----------------------------------------------------
-- Syntax highlighting and parsing plugins.
-- Mission: Tree-sitter syntax highlighting, indentation, autotag, and markdown/plantuml rendering.
return {
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "HiPhish/rainbow-delimiters.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    event =  "User FileLazyLoaded",
    cmd = { "TSInstall", "TSInstallFromGrammar", "TSBufEnable", "TSBufDisable", "TSModuleInfo" },
    opts = {
      -- single list of tree-sitter languages ensured to be installed
      -- covers all file types found in ~/stilux-dotfiles/.config plus common dev languages
      ensured_install = {
        -- Core / Neovim
        "lua",
        "luadoc",
        "vim",
        "vimdoc",

        -- Web / frontend
        "javascript",
        "typescript",
        "tsx",
        "jsx",
        "html",
        "css",
        "scss",
        "svelte",
        "vue",
        "json",
        "jsonc",

        -- Config / markup (dotfiles heavy)
        "toml",
        "yaml",
        "ini",
        "markdown",
        "markdown_inline",
        "xml",
        "editorconfig",
        "gitignore",
        "dockerfile",
        "cmake",
        "make",
        "kdl",

        -- System / backend
        "c",
        "cpp",
        "rust",
        "go",
        "zig",
        "dart",
        "python",
        "bash",
        "zsh",
        "sh",
        "java",
        "kotlin",
        "c_sharp",
        "ruby",
        "php",
        "swift",
        "scala",
        "clojure",
        "elixir",
        "erlang",
        "haskell",
        "ocaml",
        "fsharp",
        "perl",
        "r",
        "matlab",
        "julia",

        -- Misc / query
        "comment",
        "diff",
        "regex",
        "sql",
        "graphql",
        "http",
        "protobuf",
        "latex",
        "nix",
      },
    },
    config = function(_, opts)
      local TS = require("nvim-treesitter")
      local parsers = require("nvim-treesitter.parsers")

      -- setup treesitter once
      TS.setup(opts)

      -- install list is the single ensured_install table
      local ensured_install = opts.ensured_install or {}

      -- compute installed parser set once (single filesystem scan)
      local installed = {}
      for _, lang in ipairs(TS.get_installed()) do
        installed[lang] = true
      end

      -- install any parsers from ensured_install that are missing on startup
      -- (batched into a single async TS.install call)
      local missing = {}
      for _, lang in ipairs(ensured_install) do
        if not installed[lang] then
          missing[#missing + 1] = lang
        end
      end
      if #missing > 0 then
        TS.install(missing, { summary = true })
        for _, lang in ipairs(missing) do
          installed[lang] = true
        end
      end

      -- cache filetype -> language mapping to avoid repeated get_lang calls
      local lang_cache = {}

      -- auto install treesitter language parser when opening a file whose
      -- parser is not yet installed, and enable highlighting/indentation
      -- (on-demand, mirrors LazyVim behavior)
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("treesitter_auto_install", { clear = true }),
        callback = function(ev)
          local ft = ev.match
          local lang = lang_cache[ft]
          if lang == nil then
            lang = vim.treesitter.language.get_lang(ft)
            lang_cache[ft] = lang
          end
          if not lang then
            return
          end
          -- skip languages that have no tree-sitter parser (e.g. snacks_notif)
          if not parsers[lang] then
            return
          end
          -- install the parser on first use if it is not yet installed
          if not installed[lang] then
            TS.install(lang, {})
            installed[lang] = true -- optimistic mark to avoid re-triggering
          end
          -- enable syntax highlighting for the buffer
          vim.treesitter.start()
          -- enable indentation via treesitter (only set once per buffer)
          vim.bo[ev.buf].indentexpr = "v:lua.vim.treesitter.indentexpr()"
        end,
      })
    end,
  },

  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = "markdown",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    main = "render-markdown",
    opts = {
      code = {
        sign = false,
        width = "block",
        right_pad = 1,
      },
      heading = {
        sign = false,
        icons = {},
      },
      paragraph = {
        sign = false,
        padding = false,
      },
    },
  },
  -- Support for PlantUML
  {
    "aklt/plantuml-syntax",
    ft = "plantuml",
  },

  {
    "https://gitlab.com/itaranto/plantuml.nvim",
    ft = "plantuml",
    cmd = "PlantUml",
    opts = {
      renderer = {
        type = "image",
        options = {
          prog = "feh",
          dark_mode = true,
        },
      },
      render_on_write = true,
    },
    main = "plantuml",
  },
}
