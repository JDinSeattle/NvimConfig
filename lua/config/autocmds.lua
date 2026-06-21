local transparent_groups = {
  "Normal",
  "NormalNC",
  "NormalFloat",
  "FloatBorder",
  "FloatTitle",
  "SignColumn",
  "FoldColumn",
  "LineNr",
  "CursorLineNr",
  "EndOfBuffer",
  "NeoTreeNormal",
  "NeoTreeNormalNC",
  "NeoTreeEndOfBuffer",
  "TelescopeNormal",
  "TelescopeBorder",
  "TelescopePromptNormal",
  "TroubleNormal",
  "TroubleNormalNC",
  "WhichKeyNormal",
}

local function make_transparent()
  for _, group in ipairs(transparent_groups) do
    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
    if ok then
      hl.bg = "NONE"
      hl.ctermbg = nil
      pcall(vim.api.nvim_set_hl, 0, group, hl)
    end
  end
end

local readable_groups = {
  dark = {
    Comment = { fg = "#bac2de", italic = true },
    CursorLine = { bg = "#242638" },
    CursorLineNr = { fg = "#f5e0dc", bold = true },
    ColorColumn = { bg = "#313244" },
    DiagnosticUnnecessary = { fg = "#8b93b8" },
    IblIndent = { fg = "#585b70" },
    IblScope = { fg = "#bac2de" },
    LineNr = { fg = "#8b93b8" },
    LspCodeLens = { fg = "#bac2de" },
    LspCodeLensSeparator = { fg = "#8b93b8" },
    LspInlayHint = { fg = "#d7ddff", bg = "#313244", italic = true },
    LspInlayHints = { fg = "#d7ddff", bg = "#313244", italic = true },
    NonText = { fg = "#8b93b8" },
    SnacksIndent = { fg = "#585b70" },
    SnacksIndentScope = { fg = "#bac2de" },
    SpecialKey = { fg = "#8b93b8" },
    Whitespace = { fg = "#6c7086" },
  },
  light = {
    Comment = { fg = "#6c6f85", italic = true },
    CursorLine = { bg = "#eff1f5" },
    CursorLineNr = { fg = "#dc8a78", bold = true },
    ColorColumn = { bg = "#e6e9ef" },
    DiagnosticUnnecessary = { fg = "#9ca0b0" },
    IblIndent = { fg = "#bcc0cc" },
    IblScope = { fg = "#6c6f85" },
    LineNr = { fg = "#8c8fa1" },
    LspCodeLens = { fg = "#6c6f85" },
    LspCodeLensSeparator = { fg = "#9ca0b0" },
    LspInlayHint = { fg = "#5c5f77", bg = "#e6e9ef", italic = true },
    LspInlayHints = { fg = "#5c5f77", bg = "#e6e9ef", italic = true },
    NonText = { fg = "#9ca0b0" },
    SnacksIndent = { fg = "#bcc0cc" },
    SnacksIndentScope = { fg = "#6c6f85" },
    SpecialKey = { fg = "#9ca0b0" },
    Whitespace = { fg = "#acb0be" },
  },
}

local function make_readable()
  for group, hl in pairs(readable_groups[vim.o.background] or readable_groups.dark) do
    pcall(vim.api.nvim_set_hl, 0, group, hl)
  end
end

local function refresh_wallpaper_theme()
  if vim.o.background == "dark" then
    make_transparent()
  end
  make_readable()
end

local function schedule_wallpaper_theme()
  refresh_wallpaper_theme()
  for _, delay in ipairs({ 50, 250, 1000 }) do
    vim.defer_fn(refresh_wallpaper_theme, delay)
  end
end

vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
  group = vim.api.nvim_create_augroup("user_terminal_wallpaper", { clear = true }),
  callback = schedule_wallpaper_theme,
})

vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
  group = vim.api.nvim_create_augroup("user_terminal_wallpaper_refresh", { clear = true }),
  callback = schedule_wallpaper_theme,
})

vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  group = vim.api.nvim_create_augroup("user_terminal_wallpaper_lazy", { clear = true }),
  callback = schedule_wallpaper_theme,
})

schedule_wallpaper_theme()
vim.schedule(schedule_wallpaper_theme)
_G.UserRefreshWallpaperTheme = schedule_wallpaper_theme

local system_filetypes = {
  c = true,
  cpp = true,
  cuda = true,
  objc = true,
  objcpp = true,
}

local function apply_system_indent(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  local filetype = vim.bo[bufnr].filetype
  if not system_filetypes[filetype] then
    return
  end

  vim.bo[bufnr].expandtab = true
  vim.bo[bufnr].tabstop = 4
  vim.bo[bufnr].shiftwidth = 4
  vim.bo[bufnr].softtabstop = 4
  vim.bo[bufnr].autoindent = true
  vim.bo[bufnr].smartindent = true
  vim.bo[bufnr].cindent = true
  vim.bo[bufnr].cinoptions = "l1,t0,g0,(0,W4"
end

vim.api.nvim_create_autocmd({ "FileType", "BufEnter" }, {
  pattern = { "c", "cpp", "cuda", "objc", "objcpp" },
  group = vim.api.nvim_create_augroup("user_system_indent", { clear = true }),
  callback = function(event)
    apply_system_indent(event.buf)
  end,
})

vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  group = vim.api.nvim_create_augroup("user_system_indent_lazy", { clear = true }),
  callback = function()
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
      apply_system_indent(bufnr)
    end
  end,
})

local function save_modified_file_buffers()
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if
      vim.api.nvim_buf_is_valid(bufnr)
      and vim.bo[bufnr].modified
      and vim.bo[bufnr].buftype == ""
      and not vim.bo[bufnr].readonly
      and vim.api.nvim_buf_get_name(bufnr) ~= ""
    then
      pcall(vim.api.nvim_buf_call, bufnr, function()
        vim.cmd("silent write")
      end)
    end
  end
end

vim.api.nvim_create_autocmd("FocusLost", {
  group = vim.api.nvim_create_augroup("user_focus_lost_save", { clear = true }),
  callback = save_modified_file_buffers,
})
