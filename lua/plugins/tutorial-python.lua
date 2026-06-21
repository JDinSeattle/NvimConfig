local function append_unique(list, values)
  for _, value in ipairs(values) do
    if not vim.tbl_contains(list, value) then
      table.insert(list, value)
    end
  end
end

local function autoformat_enabled()
  if vim.b.autoformat ~= nil then
    return vim.b.autoformat
  end
  if vim.g.autoformat == nil then
    return true
  end
  return vim.g.autoformat
end

return {
  {
    "linux-cultist/venv-selector.nvim",
    ft = "python",
    cmd = "VenvSelect",
    keys = {
      { "<leader>cv", "<cmd>VenvSelect<cr>", desc = "[Python] Select virtualenv", ft = "python" },
    },
    opts = {
      settings = {
        options = {
          notify_user_on_venv_activation = true,
        },
      },
    },
  },

  {
    "stevearc/conform.nvim",
    optional = true,
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        group = vim.api.nvim_create_augroup("user_tutorial_format_toggle", { clear = true }),
        callback = function()
          local ok, Snacks = pcall(require, "snacks")
          if ok and Snacks.toggle then
            Snacks.toggle
              .new({
                id = "auto_format",
                name = "Auto Format",
                get = autoformat_enabled,
                set = function(state)
                  vim.g.autoformat = state
                  vim.b.autoformat = nil
                end,
              })
              :map("<leader>tf")
            return
          end

          vim.keymap.set("n", "<leader>tf", function()
            vim.g.autoformat = not autoformat_enabled()
            vim.b.autoformat = nil
            vim.notify("Auto Format: " .. (vim.g.autoformat and "enabled" or "disabled"))
          end, { desc = "[Format] Toggle auto format" })
        end,
      })
    end,
  },

  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft or {}
      opts.linters_by_ft.markdown = opts.linters_by_ft.markdown or {}
      opts.linters_by_ft.gitcommit = opts.linters_by_ft.gitcommit or {}
      opts.linters_by_ft.text = opts.linters_by_ft.text or {}

      append_unique(opts.linters_by_ft.markdown, { "codespell" })
      append_unique(opts.linters_by_ft.gitcommit, { "codespell" })
      append_unique(opts.linters_by_ft.text, { "codespell" })
    end,
  },
}
