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
vim.keymap.set({ "n", "x", "o" }, "H", "^", { desc = "Start of line" })
vim.keymap.set({ "n", "x", "o" }, "L", "$", { desc = "End of line" })
vim.keymap.set("n", "<A-z>", "<cmd>set wrap!<cr>", { desc = "Toggle line wrap" })
vim.keymap.set("n", "<leader>L", "<cmd>Lazy<cr>", { desc = "Open Lazy.nvim" })

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
