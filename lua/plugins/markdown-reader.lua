local markdown_filetypes = {
  markdown = true,
  ["markdown.mdx"] = true,
}

local reader_options = {
  wrap = true,
  linebreak = true,
  breakindent = true,
  list = false,
  number = false,
  relativenumber = false,
  signcolumn = "no",
  foldcolumn = "0",
  colorcolumn = "",
  spell = false,
  conceallevel = 2,
  concealcursor = "nc",
}

local function is_markdown(buf)
  return markdown_filetypes[vim.bo[buf or 0].filetype] == true
end

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = "Markdown" })
end

local function set_render_markdown(enabled)
  local ok, render_markdown = pcall(require, "render-markdown")
  if not ok then
    return
  end

  if enabled and render_markdown.buf_enable then
    render_markdown.buf_enable()
  elseif not enabled and render_markdown.buf_disable then
    render_markdown.buf_disable()
  end
end

local function diagnostics_enabled(buf)
  return vim.diagnostic.is_enabled({ bufnr = buf or 0 })
end

local function set_diagnostics(buf, enabled)
  vim.diagnostic.enable(enabled, { bufnr = buf })
end

local function toggle_diagnostics()
  local buf = vim.api.nvim_get_current_buf()
  if not is_markdown(buf) then
    notify("Markdown diagnostics toggle only works in Markdown buffers", vim.log.levels.WARN)
    return
  end

  local enabled = not diagnostics_enabled(buf)
  set_diagnostics(buf, enabled)
  notify("Diagnostics " .. (enabled and "on" or "off"))
end

local function save_window_options()
  local saved = {
    diagnostics = diagnostics_enabled(0),
    render_markdown = nil,
    options = {},
  }

  local ok, render_markdown = pcall(require, "render-markdown")
  if ok and render_markdown.get then
    saved.render_markdown = render_markdown.get()
  end

  for option in pairs(reader_options) do
    saved.options[option] = vim.wo[option]
  end

  return saved
end

local function restore_window_options(saved)
  if not saved then
    return
  end

  for option, value in pairs(saved.options or {}) do
    vim.wo[option] = value
  end

  if saved.render_markdown ~= nil then
    set_render_markdown(saved.render_markdown)
  end

  set_diagnostics(0, saved.diagnostics)
end

local function toggle_reader()
  local buf = vim.api.nvim_get_current_buf()
  if not is_markdown(buf) then
    notify("Reader mode only works in Markdown buffers", vim.log.levels.WARN)
    return
  end

  if vim.w.markdown_reader_enabled then
    restore_window_options(vim.w.markdown_reader_saved)
    vim.w.markdown_reader_enabled = false
    vim.w.markdown_reader_saved = nil
    notify("Reader mode off")
    return
  end

  vim.w.markdown_reader_saved = save_window_options()
  for option, value in pairs(reader_options) do
    vim.wo[option] = value
  end
  set_render_markdown(true)
  set_diagnostics(buf, false)
  vim.w.markdown_reader_enabled = true
  notify("Reader mode on")
end

return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    keys = {
      {
        "<leader>mr",
        toggle_reader,
        ft = { "markdown", "markdown.mdx" },
        desc = "Markdown Reader Mode",
      },
      {
        "<leader>ml",
        toggle_diagnostics,
        ft = { "markdown", "markdown.mdx" },
        desc = "Markdown Diagnostics",
      },
    },
  },
  {
    "iamcco/markdown-preview.nvim",
    keys = {
      {
        "<leader>mp",
        "<cmd>MarkdownPreviewToggle<cr>",
        ft = { "markdown", "markdown.mdx" },
        desc = "Markdown Preview",
      },
    },
  },
}
