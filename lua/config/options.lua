-- Options are loaded before lazy.nvim starts.

vim.g.autoformat = true
vim.g.markdown_recommended_style = 0

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

vim.opt.completeopt = "menu,menuone,noselect"
vim.opt.confirm = true
vim.opt.cursorline = true
vim.opt.guicursor = table.concat({
  "n-v-c-sm:block-Cursor",
  "i-ci-ve:ver25-CursorInsert",
  "r-cr-o:hor20-CursorReplace",
  "t:block-TermCursor",
  "a:blinkwait700-blinkoff250-blinkon250",
}, ",")
vim.opt.inccommand = "nosplit"
vim.opt.jumpoptions = "view"
vim.opt.laststatus = 3
vim.opt.linebreak = true
vim.opt.mouse = "a"
vim.opt.pumblend = 10
vim.opt.pumheight = 10
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.ruler = false
vim.opt.scrolloff = 5
vim.opt.shiftround = true
vim.opt.showmode = false
vim.opt.sidescrolloff = 10
vim.opt.smoothscroll = true
vim.opt.spelllang = { "en" }
vim.opt.startofline = false
vim.opt.timeoutlen = 300
vim.opt.undofile = true
vim.opt.undolevels = 10000
vim.opt.updatetime = 200
vim.opt.virtualedit = "block"
vim.opt.wildmode = "longest:full,full"
vim.opt.winminwidth = 5
vim.opt.clipboard = vim.env.SSH_CONNECTION and "" or "unnamedplus"
vim.opt.conceallevel = 2
vim.opt.signcolumn = "yes:1"
vim.opt.statuscolumn = [[%!v:lua.require'snacks.statuscolumn'.get()]]
vim.opt.wrap = false
vim.opt.shortmess:append({ W = true, I = true, c = true, C = true })

vim.opt.splitbelow = true
vim.opt.splitright = true

if vim.fn.has("nvim-0.11") == 1 then
  vim.o.winborder = "rounded"
end
