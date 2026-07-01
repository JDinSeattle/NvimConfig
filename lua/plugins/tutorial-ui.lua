return {
  {
    "nvim-tree/nvim-web-devicons",
    opts = {
      override = {
        copilot = {
          icon = "C",
          color = "#cba6f7",
          name = "Copilot",
        },
      },
    },
  },

  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts = {
      notification = {
        window = {
          winblend = 0,
          border = "rounded",
        },
      },
    },
  },

  {
    "folke/which-key.nvim",
    opts = function(_, opts)
      opts.spec = opts.spec or {}
      vim.list_extend(opts.spec, {
        { "<leader>b", group = "buffers" },
        { "<leader>c", group = "code" },
        { "<leader>g", group = "git" },
        { "<leader>gg", group = "git actions" },
        { "<leader>q", group = "quit/session" },
        { "<leader>r", group = "run/build" },
        { "<leader>s", group = "search/snacks" },
        { "<leader>t", group = "toggles" },
        { "<leader>u", group = "ui/toggles" },
        { "<leader>w", group = "windows" },
        { "<leader>x", group = "diagnostics/lists" },
        { "<leader>D", group = "dap view" },
      })
    end,
  },

  {
    "HiPhish/rainbow-delimiters.nvim",
    main = "rainbow-delimiters.setup",
    submodules = false,
    opts = {},
  },

  {
    "folke/noice.nvim",
    optional = true,
    opts = {
      popupmenu = {
        enabled = false,
      },
      notify = {
        enabled = false,
      },
      lsp = {
        progress = {
          enabled = false,
        },
        signature = {
          enabled = true,
          auto_open = {
            enabled = false,
          },
        },
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = false,
          ["vim.lsp.util.stylize_markdown"] = false,
        },
      },
      presets = {
        command_palette = true,
        long_message_to_split = true,
        lsp_doc_border = true,
      },
      routes = {
        { filter = { event = "msg_show", kind = "search_count" }, opts = { skip = true } },
        { filter = { event = "msg_show", kind = "" }, opts = { skip = true } },
      },
    },
  },

  {
    "petertriho/nvim-scrollbar",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      handlers = {
        cursor = true,
        diagnostic = true,
        gitsigns = true,
        handle = true,
        search = true,
      },
      excluded_buftypes = {
        "terminal",
        "nofile",
      },
      marks = {
        Search = { color = "#cba6f7" },
        GitAdd = { text = "|" },
        GitChange = { text = "|" },
        GitDelete = { text = "_" },
      },
    },
    config = function(_, opts)
      require("scrollbar").setup(opts)
      pcall(function()
        require("scrollbar.handlers.gitsigns").setup()
      end)
    end,
  },

  {
    "kevinhwang91/nvim-hlslens",
    dependencies = { "petertriho/nvim-scrollbar" },
    keys = {
      {
        "n",
        "nzz<cmd>lua require('hlslens').start()<cr>",
        mode = "n",
        desc = "[Search] Next match",
        noremap = true,
        silent = true,
      },
      {
        "N",
        "Nzz<cmd>lua require('hlslens').start()<cr>",
        mode = "n",
        desc = "[Search] Previous match",
        noremap = true,
        silent = true,
      },
      {
        "*",
        "*<cmd>lua require('hlslens').start()<cr>",
        mode = "n",
        desc = "[Search] Next word",
        noremap = true,
        silent = true,
      },
      {
        "#",
        "#<cmd>lua require('hlslens').start()<cr>",
        mode = "n",
        desc = "[Search] Previous word",
        noremap = true,
        silent = true,
      },
      {
        "g*",
        "g*<cmd>lua require('hlslens').start()<cr>",
        mode = "n",
        desc = "[Search] Next partial word",
        noremap = true,
        silent = true,
      },
      {
        "g#",
        "g#<cmd>lua require('hlslens').start()<cr>",
        mode = "n",
        desc = "[Search] Previous partial word",
        noremap = true,
        silent = true,
      },
      { "//", "<cmd>noh<cr>", mode = "n", desc = "[Search] Clear highlight", noremap = true, silent = true },
    },
    opts = {
      nearest_only = true,
    },
    config = function(_, opts)
      require("hlslens").setup(opts)
      require("scrollbar.handlers.search").setup(opts)
      vim.api.nvim_set_hl(0, "HlSearchLens", { link = "CurSearch" })
      vim.api.nvim_set_hl(0, "HlSearchLensNear", { fg = "#cba6f7" })
    end,
  },

  {
    "norcalli/nvim-colorizer.lua",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "ColorizerAttachToBuffer", "ColorizerDetachFromBuffer", "ColorizerReloadAllBuffers", "ColorizerToggle" },
    config = function()
      require("colorizer").setup()
    end,
  },

  {
    "nvzone/showkeys",
    cmd = "ShowkeysToggle",
    dependencies = { "nvzone/volt" },
    opts = {
      maxkeys = 5,
    },
  },

  {
    "kevinhwang91/nvim-ufo",
    event = "BufReadPost",
    dependencies = { "kevinhwang91/promise-async" },
    opts = {
      provider_selector = function()
        return { "treesitter", "indent" }
      end,
      open_fold_hl_timeout = 0,
    },
    init = function()
      vim.o.foldenable = true
      vim.o.foldcolumn = "0"
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
      vim.opt.fillchars:append({
        fold = " ",
        foldopen = "-",
        foldsep = " ",
        foldclose = "+",
      })
    end,
    config = function(_, opts)
      local ufo = require("ufo")
      ufo.setup(opts)

      vim.api.nvim_create_autocmd("BufReadPre", {
        group = vim.api.nvim_create_augroup("user_tutorial_ufo", { clear = true }),
        callback = function()
          vim.b.ufo_foldlevel = 0
        end,
      })

      local function set_buf_foldlevel(level)
        vim.b.ufo_foldlevel = level
        ufo.closeFoldsWith(level)
      end

      local function change_buf_foldlevel_by(amount)
        local foldlevel = vim.b.ufo_foldlevel or 0
        set_buf_foldlevel(math.max(foldlevel + amount, 0))
      end

      vim.keymap.set("n", "K", function()
        local winid = ufo.peekFoldedLinesUnderCursor()
        if not winid then
          vim.lsp.buf.hover()
        end
      end, { desc = "[UFO] Peek fold or hover" })

      vim.keymap.set("n", "zM", function()
        set_buf_foldlevel(0)
      end, { desc = "[UFO] Close all folds" })
      vim.keymap.set("n", "zR", ufo.openAllFolds, { desc = "[UFO] Open all folds" })
      vim.keymap.set("n", "zm", function()
        change_buf_foldlevel_by(-(vim.v.count == 0 and 1 or vim.v.count))
      end, { desc = "[UFO] Fold more" })
      vim.keymap.set("n", "zr", function()
        change_buf_foldlevel_by(vim.v.count == 0 and 1 or vim.v.count)
      end, { desc = "[UFO] Fold less" })
      vim.keymap.set("n", "zS", function()
        if vim.v.count == 0 then
          vim.notify("No foldlevel given to set", vim.log.levels.WARN)
        else
          set_buf_foldlevel(vim.v.count)
        end
      end, { desc = "[UFO] Set foldlevel" })
    end,
  },

  {
    "mikavilpas/yazi.nvim",
    dependencies = { "folke/snacks.nvim" },
    keys = {
      { "<leader>E", "<cmd>Yazi<cr>", desc = "[Yazi] Open at current file", mode = { "n", "v" } },
      { "<leader>cw", "<cmd>Yazi cwd<cr>", desc = "[Yazi] Open cwd" },
      { "<c-up>", "<cmd>Yazi toggle<cr>", desc = "[Yazi] Resume session" },
    },
    opts = {
      open_for_directories = false,
      keymaps = {
        show_help = "<f1>",
      },
    },
    init = function()
      vim.g.loaded_netrwPlugin = 1
    end,
  },
}
