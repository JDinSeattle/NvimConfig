return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "auto",
      background = {
        light = "latte",
        dark = "mocha",
      },
      transparent_background = false,
      integrations = {
        blink_cmp = true,
        cmp = true,
        dap = true,
        dap_ui = true,
        flash = true,
        gitsigns = true,
        lsp_trouble = true,
        mason = true,
        native_lsp = { enabled = true },
        neotree = true,
        noice = true,
        rainbow_delimiters = true,
        snacks = {
          enabled = true,
          indent_scope_color = "flamingo",
        },
        telescope = true,
        treesitter = true,
        which_key = true,
      },
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme("catppuccin")
    end,
  },
}
