-- Set leader before loading plugins so every keymap sees the same prefix.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Bootstrap lazy.nvim and the local Neovim config.
require("config.lazy")
