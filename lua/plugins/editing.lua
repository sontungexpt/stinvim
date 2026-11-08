-- ------------------------------------------------- Editing -------------------------------------------------
-- Text editing enhancement plugins.
-- Mission: Improve the core editing experience (commenting code, indentation guides, color picker).
return {
  -- Support comment
  {
    "numToStr/Comment.nvim",
    event = "User FileLazyLoaded",
    dependencies = {
      {
        "JoosepAlviste/nvim-ts-context-commentstring",
        dependencies = {
          "nvim-treesitter/nvim-treesitter",
        },
        opts = {
          enable_autocmd = false,
        },
      },
    },
    opts = {
      ignore = "^$",
      pre_hook = function(ctx)
        local U = require("Comment.utils")
        local location = nil
        if ctx.ctype == U.ctype.line then
          location = require("ts_context_commentstring.utils").get_cursor_location()
        elseif ctx.cmotion == U.cmotion.v or ctx.cmotion == U.cmotion.V then
          location = require("ts_context_commentstring.utils").get_virtual_location()
        end
        return require("ts_context_commentstring.internal").calculate_commentstring({
          key = location or { cmotion = ctx.cmotion, ctype = ctx.ctype },
        })
      end,
    },
  },

  -- Auto indent
  {
    "lukas-reineke/indent-blankline.nvim",
    event = "User FileLazyLoaded",
    main = "ibl",
    dependencies = {
      "HiPhish/rainbow-delimiters.nvim",
    },
    opts = function()
      local hooks = require("ibl.hooks")
      hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
      return {
        indent = {
          char = "│",
        },
        scope = {
          char = "│",
          show_start = false,
        },
        exclude = {
          filetypes = { "alpha", "dashboard", "Trouble", "lazy", "NvimTree", "mason" },
        },
      }
    end,
  },

  -- Color picker: pick a color and insert its value into the buffer
  {
    "uga-rosa/ccc.nvim",
    cmd = "CccPick",
    opts = {},
  },

  -- Color hex highlighting: shows background color for color codes (#RRGGBB, rgb(), etc.)
  {
    "brenoprata10/nvim-highlight-colors",
    event = "User FileLazyLoaded",
    opts = {},
  },

  -- Smart window resizing: resize windows with arrow keys
  {
    dir = "/home/stilux/Data/workspace/neovim-plugins/smart-resizing",
    -- "sontungexpt/smart-resizing",
    opts = {},
  },

  -- Flash: enhanced search and motion with labels (s, S, f, F, t, T, etc.)
  -- {
  --   "folke/flash.nvim",
  --   event = "VeryLazy",
  --   ---@type Flash.Config
  --   opts = {},
  --   keys = {
  --     { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
  --     { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
  --     { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
  --     { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Flash Treesitter Search" },
  --     { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
  --   },
  -- },
}
