local function run_in_terminal(command)
  vim.cmd("botright 15split")
  vim.cmd("terminal " .. command)
  vim.cmd("startinsert")
end

local function save_current_file()
  if vim.bo.modified then
    vim.cmd.write()
  end
end

vim.keymap.set("i", "jk", "<Esc>", { desc = "Exit insert mode" })
vim.keymap.set("i", "<C-h>", "<Left>", { desc = "Move left" })
vim.keymap.set("i", "<C-l>", "<Right>", { desc = "Move right" })
vim.keymap.set("i", "<C-j>", "<Down>", { desc = "Move down" })
vim.keymap.set("i", "<C-k>", "<Up>", { desc = "Move up" })
vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
vim.keymap.set({ "n", "x", "o" }, "H", "^", { desc = "Start of line" })
vim.keymap.set({ "n", "x", "o" }, "L", "$", { desc = "End of line" })
vim.keymap.set("n", "[b", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
vim.keymap.set("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to other buffer" })
vim.keymap.set("n", "<leader>`", "<cmd>e #<cr>", { desc = "Switch to other buffer" })
vim.keymap.set("n", "<A-z>", "<cmd>set wrap!<cr>", { desc = "Toggle line wrap" })
vim.keymap.set("n", "<leader>L", "<cmd>Lazy<cr>", { desc = "Open Lazy.nvim" })

vim.keymap.set("n", "<A-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move line up" })
vim.keymap.set("i", "<A-j>", "<Esc><cmd>m .+1<cr>==gi", { desc = "Move line down" })
vim.keymap.set("i", "<A-k>", "<Esc><cmd>m .-2<cr>==gi", { desc = "Move line up" })
vim.keymap.set("x", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move selection down" })
vim.keymap.set("x", "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move selection up" })
vim.keymap.set("x", "<", "<gv", { desc = "Indent left" })
vim.keymap.set("x", ">", ">gv", { desc = "Indent right" })
vim.keymap.set("i", ",", ",<C-g>u")
vim.keymap.set("i", ".", ".<C-g>u")
vim.keymap.set("i", ";", ";<C-g>u")
vim.keymap.set({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })
vim.keymap.set("n", "<D-c>", '"+yy', { desc = "Copy line to system clipboard" })
vim.keymap.set("x", "<D-c>", '"+y', { desc = "Copy selection to system clipboard" })
vim.keymap.set("n", "<leader>ur", "<cmd>nohlsearch|diffupdate|normal! <C-L><cr>", { desc = "Redraw and clear search" })
vim.keymap.set("n", "<leader>K", "<cmd>norm! K<cr>", { desc = "Keywordprg" })
vim.keymap.set("n", "gco", "o<Esc>Vcx<Esc><cmd>normal gcc<cr>fxa<BS>", { desc = "Add comment below" })
vim.keymap.set("n", "gcO", "O<Esc>Vcx<Esc><cmd>normal gcc<cr>fxa<BS>", { desc = "Add comment above" })
vim.keymap.set("n", "<leader>xl", function()
  local ok, err = pcall(vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 and vim.cmd.lclose or vim.cmd.lopen)
  if not ok and err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end, { desc = "Location list" })
vim.keymap.set("n", "<leader>xq", function()
  local ok, err = pcall(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.cmd.copen)
  if not ok and err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end, { desc = "Quickfix list" })

local function set_day_night_theme(mode)
  local is_day = mode == "day"
  vim.o.background = is_day and "light" or "dark"
  vim.cmd.colorscheme(is_day and "catppuccin-latte" or "catppuccin-mocha")
  vim.schedule(function()
    if _G.UserRefreshWallpaperTheme then
      _G.UserRefreshWallpaperTheme()
    end
  end)
  vim.notify("Theme: " .. (is_day and "day" or "night"))
end

vim.keymap.set("n", "<leader>uB", function()
  set_day_night_theme(vim.o.background == "dark" and "day" or "night")
end, { desc = "Toggle Day/Night Theme" })
vim.keymap.set("n", "<leader>ub", function()
  set_day_night_theme(vim.o.background == "dark" and "day" or "night")
end, { desc = "Toggle Day/Night Theme" })

local function compile_and_run_current_file()
  local ft = vim.bo.filetype
  local compilers = {
    c = { compiler = "clang", flags = "-std=c11 -Wall -Wextra -Wpedantic -g -O0" },
    cpp = { compiler = "clang++", flags = "-std=c++20 -Wall -Wextra -Wpedantic -g -O0" },
  }
  local spec = compilers[ft]
  if not spec then
    vim.notify("Compile & Run is only configured for C/C++ files", vim.log.levels.WARN)
    return
  end

  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    vim.notify("Save the file before compiling", vim.log.levels.WARN)
    return
  end

  save_current_file()

  local cwd = vim.fn.getcwd()
  local build_dir = cwd .. "/.build"
  vim.fn.mkdir(build_dir, "p")

  local output = build_dir .. "/" .. vim.fn.fnamemodify(file, ":t:r")
  local command = table.concat({
    spec.compiler,
    spec.flags,
    vim.fn.shellescape(file),
    "-o",
    vim.fn.shellescape(output),
    "&&",
    vim.fn.shellescape(output),
  }, " ")

  run_in_terminal(command)
end

vim.keymap.set("n", "<leader>rr", compile_and_run_current_file, { desc = "Compile & Run C/C++ File" })
vim.keymap.set("n", "<leader>rm", function()
  save_current_file()
  run_in_terminal("make")
end, { desc = "Run make" })
vim.keymap.set("n", "<leader>rM", function()
  save_current_file()
  run_in_terminal("make test")
end, { desc = "Run make test" })
vim.keymap.set("n", "<leader>rb", function()
  save_current_file()
  run_in_terminal("cmake --build build")
end, { desc = "Build CMake project" })
vim.keymap.set("n", "<leader>rt", function()
  save_current_file()
  run_in_terminal("ctest --test-dir build --output-on-failure")
end, { desc = "Run CTest" })
