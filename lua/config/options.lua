-- Options are loaded before lazy.nvim starts.

vim.opt.list = true
vim.opt.listchars = {
  tab = "> ",
  trail = ".",
  extends = ">",
  precedes = "<",
  nbsp = "+",
}

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true

vim.opt.scrolloff = 5
vim.opt.sidescrolloff = 10
vim.opt.startofline = false
vim.opt.updatetime = 200
vim.opt.clipboard = "unnamedplus"
vim.opt.conceallevel = 2
vim.opt.signcolumn = "yes:1"
vim.opt.wrap = false

vim.opt.splitbelow = true
vim.opt.splitright = true

if vim.fn.has("nvim-0.11") == 1 then
  vim.o.winborder = "rounded"
end
