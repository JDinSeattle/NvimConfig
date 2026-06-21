return {
  {
    "igorlfs/nvim-dap-view",
    dependencies = {
      {
        "nvim-lualine/lualine.nvim",
        optional = true,
        opts = function(_, opts)
          opts.options = opts.options or {}
          opts.options.disabled_filetypes = opts.options.disabled_filetypes or {}
          opts.options.disabled_filetypes.winbar = vim.list_extend(opts.options.disabled_filetypes.winbar or {}, {
            "dap-view",
            "dap-view-term",
            "dap-repl",
          })
        end,
      },
    },
    keys = {
      {
        "<leader>du",
        function()
          require("dap-view").toggle()
        end,
        desc = "[DAP View] Toggle",
      },
    },
    opts = {
      winbar = {
        sections = { "scopes", "repl", "watches", "breakpoints", "exceptions" },
        default_section = "scopes",
        controls = {
          enabled = true,
        },
      },
      windows = {
        size = 0.25,
        position = "below",
        terminal = {
          size = 0.1,
          position = "right",
          hide = {},
        },
      },
      help = {
        border = "rounded",
      },
      auto_toggle = true,
    },
  },

  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "igorlfs/nvim-dap-view",
    },
    keys = {
      {
        "<F5>",
        function()
          require("dap").continue()
        end,
        mode = "n",
        desc = "[DAP] Continue",
      },
      {
        "<F6>",
        function()
          require("dap").step_over()
        end,
        mode = "n",
        desc = "[DAP] Step over",
      },
      {
        "<F7>",
        function()
          require("dap").step_into()
        end,
        mode = "n",
        desc = "[DAP] Step into",
      },
      {
        "<F8>",
        function()
          require("dap").step_out()
        end,
        mode = "n",
        desc = "[DAP] Step out",
      },
      {
        "<F9>",
        function()
          require("dap").pause()
        end,
        mode = "n",
        desc = "[DAP] Pause",
      },
      {
        "<F10>",
        function()
          require("dap").terminate()
        end,
        mode = "n",
        desc = "[DAP] Terminate",
      },
      {
        "<leader>db",
        function()
          require("dap").toggle_breakpoint()
        end,
        mode = "n",
        desc = "[DAP] Toggle breakpoint",
      },
      {
        "<leader>dB",
        function()
          require("dap").set_breakpoint()
        end,
        mode = "n",
        desc = "[DAP] Set breakpoint",
      },
      {
        "<leader>dR",
        function()
          require("dap").repl.open()
        end,
        mode = "n",
        desc = "[DAP] Open REPL",
      },
      {
        "<leader>dl",
        function()
          require("dap").run_last()
        end,
        mode = "n",
        desc = "[DAP] Run last",
      },
      {
        "<leader>dh",
        function()
          require("dap.ui.widgets").hover()
        end,
        mode = { "n", "v" },
        desc = "[DAP] Hover",
      },
      {
        "<leader>dp",
        function()
          require("dap.ui.widgets").preview()
        end,
        mode = { "n", "v" },
        desc = "[DAP] Preview",
      },
      {
        "<leader>df",
        function()
          local widgets = require("dap.ui.widgets")
          widgets.centered_float(widgets.frames)
        end,
        mode = "n",
        desc = "[DAP] Float frames",
      },
      {
        "<leader>ds",
        function()
          local widgets = require("dap.ui.widgets")
          widgets.centered_float(widgets.scopes)
        end,
        mode = "n",
        desc = "[DAP] Float scopes",
      },
    },
    init = function()
      local signs = {
        DapBreakpoint = { text = "B", texthl = "DapBreakpoint", linehl = "DapBreakpoint", numhl = "DapBreakpoint" },
        DapBreakpointCondition = {
          text = "C",
          texthl = "DapBreakpoint",
          linehl = "DapBreakpoint",
          numhl = "DapBreakpoint",
        },
        DapBreakpointRejected = {
          text = "R",
          texthl = "DapBreakpoint",
          linehl = "DapBreakpoint",
          numhl = "DapBreakpoint",
        },
        DapLogPoint = { text = "L", texthl = "DapLogPoint", linehl = "DapLogPoint", numhl = "DapLogPoint" },
        DapStopped = { text = ">", texthl = "DapStopped", linehl = "DapStopped", numhl = "DapStopped" },
      }
      for name, sign in pairs(signs) do
        vim.fn.sign_define(name, sign)
      end
    end,
  },
}
