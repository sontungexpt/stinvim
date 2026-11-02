-- ---------------------------------------------------- Debugger ----------------------------------------------------
-- Debugging plugins (DAP - Debug Adapter Protocol).
-- Mission: Step-through debugging, breakpoints, variable inspection, and REPL integration.
return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      {
        "rcarriga/nvim-dap-ui",
        dependencies = {
          "nvim-neotest/nvim-nio",
          "jbyuki/one-small-step-for-vimkind",
        },
        main = "dapui",
        opts = {
          icons = {
            expanded = "▾",
            collapsed = "▸",
          },
          mappings = {
            expand = { "<CR>", "<2-LeftMouse>" },
            open = "o",
            remove = "d",
            edit = "e",
            repl = "r",
            toggle = "t",
          },
          floating = {
            max_height = 0.8,
            max_width = 0.8,
            border = "single",
            mappings = {
              close = { "q", "<Esc>" },
            },
          },
          windows = {
            indent = 1,
          },
        },
      },
      {
        "theHamsta/nvim-dap-virtual-text",
        opts = {
          enabled = true,
          enabled_commands = true,
          highlight_changed_variables = true,
          highlight_new_as_changed = false,
          show_stop_reason = true,
          commented = false,
          only_first_definition = true,
          all_references = false,
          clear_on_continue = false,
          display_callback = function(variable, buf, stackframe, node, options)
            if options.virt_text_pos == "inline" then
              return " = " .. variable.value
            else
              return variable.name .. " = " .. variable.value
            end
          end,
          virt_text_pos = vim.fn.has("nvim-0.10") == 1 and "inline" or "eol",
          all_frames = false,
          virt_lines = false,
          virt_text_win_col = nil,
        },
      },
    },
    config = function()
      local fn = vim.fn
      local dap = require("dap")
      local icons = require("ui.icons")

      fn.sign_define("DapBreakpoint", {
        text = icons.DapBreakpoint,
        numhl = "DapBreakpoint",
        texthl = "DapBreakpoint",
      })

      fn.sign_define("DapStopped", {
        text = icons.DapStopped,
        numhl = "DapStopped",
        texthl = "DapStopped",
      })

      local ok, dapui = pcall(require, "dapui")
      if ok then
        dap.listeners.before.attach.dapui_config = function() dapui.open() end
        dap.listeners.before.launch.dapui_config = function() dapui.open() end
        dap.listeners.after.event_terminated.dapui_config = function()
          require("dap.repl").close()
          dapui.close()
        end
        dap.listeners.before.event_exited.dapui_config = function()
          require("dap.repl").close()
          dapui.close()
        end
      end

      dap.adapters.codelldb = {
        type = "server",
        host = "127.0.0.1",
        port = 13000,
        executable = {
          command = vim.fn.exepath("codelldb"),
          args = { "--port", 13000 },
        },
      }

      dap.configurations.cpp = {
        {
          name = "Launch file",
          type = "codelldb",
          request = "launch",
          program = function() return fn.input("path to executable: ", fn.getcwd() .. "/bin/program", "file") end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
          args = {},
        },
      }
      dap.configurations.c = dap.configurations.cpp

      dap.adapters.nlua = function(callback, config)
        callback {
          type = "server",
          host = config.host or "127.0.0.1",
          port = config.port or 8086,
        }
      end

      dap.configurations.lua = {
        {
          name = "Launch file",
          type = "nlua",
          request = "attach",
          stopOnEntry = false,
          args = {},
        },
      }
    end,
  },
}
