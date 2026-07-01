local function executable(name)
  return vim.fn.executable(name) == 1
end

local function has_image_tool()
  return executable("magick") or executable("convert")
end

return {
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      local has_delta = executable("delta")

      return vim.tbl_deep_extend("force", opts or {}, {
        bigfile = { enabled = true },
        dashboard = { enabled = false },
        image = {
          enabled = has_image_tool(),
          doc = { inline = false, float = false, max_width = 80, max_height = 40 },
          math = { latex = { font_size = "small" } },
        },
        indent = {
          enabled = true,
          animate = { enabled = false },
          indent = { only_scope = true },
          scope = { enabled = true, underline = true },
          chunk = { enabled = true },
        },
        input = { enabled = true },
        lazygit = {
          enabled = true,
          configure = false,
        },
        notifier = {
          enabled = true,
          style = "notification",
        },
        picker = {
          previewers = {
            diff = has_delta and { builtin = false, cmd = { "delta" } } or { builtin = true },
            git = { builtin = not has_delta, args = {} },
          },
          sources = {
            spelling = {
              layout = { preset = "select" },
            },
          },
          win = {
            input = {
              keys = {
                ["<Tab>"] = { "select_and_prev", mode = { "i", "n" } },
                ["<S-Tab>"] = { "select_and_next", mode = { "i", "n" } },
                ["<A-Up>"] = { "history_back", mode = { "n", "i" } },
                ["<A-Down>"] = { "history_forward", mode = { "n", "i" } },
                ["<A-j>"] = { "list_down", mode = { "n", "i" } },
                ["<A-k>"] = { "list_up", mode = { "n", "i" } },
                ["<C-u>"] = { "preview_scroll_up", mode = { "n", "i" } },
                ["<C-d>"] = { "preview_scroll_down", mode = { "n", "i" } },
                ["<A-u>"] = { "list_scroll_up", mode = { "n", "i" } },
                ["<A-d>"] = { "list_scroll_down", mode = { "n", "i" } },
                ["<c-j>"] = {},
                ["<c-k>"] = {},
              },
            },
          },
          layout = {
            preset = "telescope",
          },
        },
        quickfile = { enabled = true },
        scope = {
          enabled = true,
          cursor = false,
        },
        statuscolumn = {
          enabled = true,
          left = { "mark", "sign" },
          right = { "fold", "git" },
          folds = {
            open = true,
            git_hl = false,
          },
          refresh = 50,
        },
        terminal = { enabled = true },
        words = { enabled = true },
        styles = {
          terminal = {
            relative = "editor",
            border = "rounded",
            position = "float",
            backdrop = 60,
            height = 0.9,
            width = 0.9,
            zindex = 50,
          },
        },
      })
    end,
    keys = {
      {
        "<A-w>",
        function()
          require("snacks").bufdelete()
        end,
        desc = "[Snacks] Delete buffer",
      },
      {
        "<leader>bd",
        function()
          require("snacks").bufdelete()
        end,
        desc = "[Buffer] Delete buffer",
      },
      {
        "<leader>bo",
        function()
          require("snacks").bufdelete.other()
        end,
        desc = "[Buffer] Delete other buffers",
      },
      {
        "<leader>bi",
        function()
          require("snacks").bufdelete.invisible()
        end,
        desc = "[Buffer] Delete invisible buffers",
      },
      {
        "<leader>bD",
        "<cmd>bd<cr>",
        desc = "[Buffer] Delete buffer and window",
      },
      {
        "<A-i>",
        function()
          require("snacks").terminal()
        end,
        desc = "[Snacks] Toggle terminal",
        mode = { "n", "t" },
      },
      {
        "<C-g>",
        function()
          require("snacks").lazygit()
        end,
        desc = "[Snacks] Lazygit",
      },
      {
        "<leader>n",
        function()
          require("snacks").notifier.show_history()
        end,
        desc = "[Snacks] Notification history",
      },
      {
        "<leader>si",
        function()
          require("snacks").image.hover()
        end,
        desc = "[Snacks] Display image",
      },
      {
        "<leader>sn",
        function()
          require("snacks").picker.notifications()
        end,
        desc = "[Snacks] Notification history",
      },
      {
        "<leader>un",
        function()
          require("snacks").notifier.hide()
        end,
        desc = "[Snacks] Dismiss notifications",
      },
      {
        "<leader>sf",
        function()
          require("snacks").picker.files()
        end,
        desc = "[Snacks] Find files",
      },
      {
        "<leader>sg",
        function()
          require("snacks").picker.grep()
        end,
        desc = "[Snacks] Grep",
      },
      {
        "<leader>sb",
        function()
          require("snacks").picker.buffers()
        end,
        desc = "[Snacks] Buffers",
      },
      {
        "<leader>sP",
        function()
          require("snacks").picker.projects()
        end,
        desc = "[Snacks] Projects",
      },
      {
        "<leader>sR",
        function()
          require("snacks").picker.recent()
        end,
        desc = "[Snacks] Recent",
      },
      {
        '<leader>s"',
        function()
          require("snacks").picker.registers()
        end,
        desc = "[Snacks] Registers",
      },
      {
        "<leader>s/",
        function()
          require("snacks").picker.search_history()
        end,
        desc = "[Snacks] Search history",
      },
      {
        "<leader>sa",
        function()
          require("snacks").picker.spelling()
        end,
        desc = "[Snacks] Spelling",
      },
      {
        "<leader>sA",
        function()
          require("snacks").picker.autocmds()
        end,
        desc = "[Snacks] Autocmds",
      },
      {
        "<leader>s:",
        function()
          require("snacks").picker.command_history()
        end,
        desc = "[Snacks] Command history",
      },
      {
        "<leader>sc",
        function()
          require("snacks").picker.commands()
        end,
        desc = "[Snacks] Commands",
      },
      {
        "<leader>sd",
        function()
          require("snacks").picker.diagnostics()
        end,
        desc = "[Snacks] Diagnostics",
      },
      {
        "<leader>sD",
        function()
          require("snacks").picker.diagnostics_buffer()
        end,
        desc = "[Snacks] Buffer diagnostics",
      },
      {
        "<leader>sH",
        function()
          require("snacks").picker.help()
        end,
        desc = "[Snacks] Help pages",
      },
      {
        "<leader>sh",
        function()
          require("snacks").picker.highlights()
        end,
        desc = "[Snacks] Highlights",
      },
      {
        "<leader>sI",
        function()
          require("snacks").picker.icons()
        end,
        desc = "[Snacks] Icons",
      },
      {
        "<leader>sj",
        function()
          require("snacks").picker.jumps()
        end,
        desc = "[Snacks] Jumps",
      },
      {
        "<leader>sk",
        function()
          require("snacks").picker.keymaps()
        end,
        desc = "[Snacks] Keymaps",
      },
      {
        "<leader>sl",
        function()
          require("snacks").picker.loclist()
        end,
        desc = "[Snacks] Location list",
      },
      {
        "<leader>sm",
        function()
          require("snacks").picker.marks()
        end,
        desc = "[Snacks] Marks",
      },
      {
        "<leader>sM",
        function()
          require("snacks").picker.man()
        end,
        desc = "[Snacks] Man pages",
      },
      {
        "<leader>sq",
        function()
          require("snacks").picker.qflist()
        end,
        desc = "[Snacks] Quickfix list",
      },
      {
        "<leader>sr",
        function()
          require("snacks").picker.resume()
        end,
        desc = "[Snacks] Resume",
      },
      {
        "<leader>su",
        function()
          require("snacks").picker.undo()
        end,
        desc = "[Snacks] Undo history",
      },
      {
        "<leader>ss",
        function()
          require("snacks").picker.lsp_symbols()
        end,
        desc = "[Snacks] LSP symbols",
      },
      {
        "<leader>sS",
        function()
          require("snacks").picker.lsp_workspace_symbols()
        end,
        desc = "[Snacks] Workspace symbols",
      },
      {
        "<leader>ggl",
        function()
          require("snacks").picker.git_log()
        end,
        desc = "[Snacks] Git log",
      },
      {
        "<leader>ggd",
        function()
          require("snacks").picker.git_diff()
        end,
        desc = "[Snacks] Git diff",
      },
      {
        "<leader>ggb",
        function()
          require("snacks").git.blame_line()
        end,
        desc = "[Snacks] Git blame line",
      },
      {
        "<leader>ggB",
        function()
          require("snacks").gitbrowse()
        end,
        desc = "[Snacks] Git browse",
      },
      {
        "]]",
        function()
          require("snacks").words.jump(vim.v.count1)
        end,
        desc = "[Snacks] Next reference",
        mode = { "n", "t" },
      },
      {
        "[[",
        function()
          require("snacks").words.jump(-vim.v.count1)
        end,
        desc = "[Snacks] Previous reference",
        mode = { "n", "t" },
      },
      {
        "<leader>z",
        function()
          require("snacks").zen()
        end,
        desc = "[Snacks] Toggle Zen Mode",
      },
      {
        "<leader>Z",
        function()
          require("snacks").zen.zoom()
        end,
        desc = "[Snacks] Toggle Zoom",
      },
    },
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        group = vim.api.nvim_create_augroup("user_tutorial_snacks_toggles", { clear = true }),
        callback = function()
          local ok, Snacks = pcall(require, "snacks")
          if not ok or not Snacks.toggle then
            return
          end

          local function map_toggle(factory, lhs)
            local toggle_ok, toggle = pcall(factory)
            if toggle_ok and toggle and toggle.map then
              pcall(function()
                toggle:map(lhs)
              end)
            end
          end

          local function map_toggles(factory, lhses)
            for _, lhs in ipairs(lhses) do
              map_toggle(factory, lhs)
            end
          end

          map_toggles(function()
            return Snacks.toggle.dim()
          end, { "<leader>tD", "<leader>uD" })
          map_toggles(function()
            return Snacks.toggle.option("spell", { name = "Spelling" })
          end, { "<leader>ts", "<leader>us" })
          map_toggles(function()
            return Snacks.toggle.option("wrap", { name = "Wrap" })
          end, { "<leader>tw", "<leader>uw" })
          map_toggles(function()
            return Snacks.toggle.option("relativenumber", { name = "Relative Number" })
          end, { "<leader>tL", "<leader>uL" })
          map_toggle(function()
            return Snacks.toggle.diagnostics()
          end, "<leader>td")
          map_toggles(function()
            return Snacks.toggle.line_number()
          end, { "<leader>tl", "<leader>ul" })
          map_toggles(function()
            return Snacks.toggle.option(
              "conceallevel",
              { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }
            )
          end, { "<leader>tc", "<leader>uc" })
          map_toggles(function()
            return Snacks.toggle.treesitter()
          end, { "<leader>tT", "<leader>uT" })
          map_toggles(function()
            return Snacks.toggle.inlay_hints()
          end, { "<leader>th", "<leader>uh" })
          map_toggles(function()
            return Snacks.toggle.indent()
          end, { "<leader>tg", "<leader>ug" })

          vim.api.nvim_set_hl(0, "SnacksPickerListCursorLine", { bg = "#313244" })
        end,
      })
    end,
  },
}
