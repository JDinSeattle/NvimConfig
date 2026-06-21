local icons = {
  [vim.diagnostic.severity.ERROR] = "E",
  [vim.diagnostic.severity.WARN] = "W",
  [vim.diagnostic.severity.INFO] = "I",
  [vim.diagnostic.severity.HINT] = "H",
}

vim.diagnostic.config({
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  signs = {
    text = icons,
  },
  virtual_text = {
    spacing = 4,
    source = "if_many",
    prefix = function(diagnostic)
      return icons[diagnostic.severity] or "●"
    end,
    format = function(diagnostic)
      return diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
    end,
  },
  float = {
    border = "rounded",
    focusable = false,
    header = "",
    prefix = function(diagnostic)
      return (icons[diagnostic.severity] or "●") .. " "
    end,
    source = "if_many",
  },
})

local function diagnostic_jump(next, severity)
  return function()
    vim.diagnostic.jump({
      count = (next and 1 or -1) * vim.v.count1,
      float = true,
      severity = severity and vim.diagnostic.severity[severity] or nil,
    })
  end
end

vim.keymap.set("n", "<leader>cd", vim.diagnostic.open_float, { desc = "[Diagnostics] Line diagnostics" })
vim.keymap.set("n", "]d", diagnostic_jump(true), { desc = "[Diagnostics] Next diagnostic" })
vim.keymap.set("n", "[d", diagnostic_jump(false), { desc = "[Diagnostics] Previous diagnostic" })
vim.keymap.set("n", "]e", diagnostic_jump(true, "ERROR"), { desc = "[Diagnostics] Next error" })
vim.keymap.set("n", "[e", diagnostic_jump(false, "ERROR"), { desc = "[Diagnostics] Previous error" })
vim.keymap.set("n", "]w", diagnostic_jump(true, "WARN"), { desc = "[Diagnostics] Next warning" })
vim.keymap.set("n", "[w", diagnostic_jump(false, "WARN"), { desc = "[Diagnostics] Previous warning" })

vim.keymap.set("n", "<leader>ud", function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "[Diagnostics] Toggle diagnostics" })
