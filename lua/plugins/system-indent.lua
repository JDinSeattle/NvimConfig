local parsers = { "c", "cpp", "go", "gomod", "gosum", "gowork", "gotmpl", "rust", "ron", "toml" }

local function append_unique(list, values)
  for _, value in ipairs(values) do
    if not vim.tbl_contains(list, value) then
      table.insert(list, value)
    end
  end
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      append_unique(opts.ensure_installed, parsers)
      opts.indent = opts.indent or {}
      opts.indent.enable = true
    end,
  },
}
