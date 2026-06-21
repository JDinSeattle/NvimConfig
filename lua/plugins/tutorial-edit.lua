return {
  {
    "mbbill/undotree",
    keys = {
      { "<leader>ut", "<cmd>UndotreeToggle<cr>", desc = "[UndoTree] Toggle undo tree" },
    },
    init = function()
      if vim.fn.has("persistent_undo") == 1 then
        local undo_dir = vim.fn.expand("~/.undodir")
        if vim.fn.isdirectory(undo_dir) == 0 then
          vim.fn.mkdir(undo_dir, "p", "0700")
        end
        vim.opt.undodir = undo_dir
        vim.opt.undofile = true
      end
    end,
  },

  {
    "jake-stewart/multicursor.nvim",
    branch = "1.0",
    event = "BufReadPost",
    keys = {
      {
        "mI",
        function()
          require("multicursor-nvim").insertVisual()
        end,
        mode = "x",
        desc = "[Multicursor] Insert cursors at selection",
      },
      {
        "mA",
        function()
          require("multicursor-nvim").appendVisual()
        end,
        mode = "x",
        desc = "[Multicursor] Append cursors at selection",
      },
    },
    config = function()
      local mc = require("multicursor-nvim")
      mc.setup()

      mc.addKeymapLayer(function(layer)
        layer("n", "<esc>", function()
          mc.clearCursors()
        end)
      end)
    end,
  },

  {
    "folke/flash.nvim",
    opts = {
      label = {
        rainbow = {
          enabled = true,
          shade = 1,
        },
      },
      modes = {
        char = {
          enabled = false,
        },
      },
    },
    keys = {
      {
        "<leader>f",
        function()
          require("flash").jump()
        end,
        mode = { "n", "x", "o" },
        desc = "[Flash] Jump",
      },
      {
        "<leader>F",
        function()
          require("flash").treesitter()
        end,
        mode = { "n", "x", "o" },
        desc = "[Flash] Treesitter",
      },
      {
        "<leader>F",
        function()
          require("flash").treesitter_search()
        end,
        mode = { "o", "x" },
        desc = "[Flash] Treesitter search",
      },
    },
  },

  {
    "folke/todo-comments.nvim",
    optional = true,
    keys = {
      {
        "<leader>st",
        function()
          require("snacks").picker.todo_comments({
            keywords = { "TODO", "FIX", "FIXME", "BUG", "FIXIT", "HACK", "WARN", "ISSUE" },
          })
        end,
        desc = "[TODO] Pick todos without NOTE",
      },
      {
        "<leader>sT",
        function()
          require("snacks").picker.todo_comments()
        end,
        desc = "[TODO] Pick todos with NOTE",
      },
    },
  },
}
