local command = vim.fn.exepath("macism")

if command == "" or vim.g.user_input_method_enabled == false then
  return
end

local default_input = vim.g.user_input_method_default or "com.apple.keylayout.ABC"
local restore_insert_input = vim.g.user_input_method_restore_insert ~= false
local last_insert_input = default_input

local function valid_input(input)
  return type(input) == "string" and input:match("^com%.") ~= nil and #input < 200
end

local function parse_input(stdout)
  for line in tostring(stdout or ""):gmatch("[^\r\n]+") do
    local input = vim.trim(line)
    if valid_input(input) then
      return input
    end
  end
end

local function run(args, callback)
  local ok = pcall(vim.system, args, { text = true }, callback)
  if not ok then
    vim.schedule(function()
      vim.notify("Failed to run input method command: " .. table.concat(args, " "), vim.log.levels.WARN)
    end)
  end
end

local function switch_to(input)
  if valid_input(input) then
    run({ command, input })
  end
end

local function switch_to_default()
  switch_to(default_input)
end

local function remember_insert_input_then_default()
  run({ command }, function(result)
    local input = result and result.code == 0 and parse_input(result.stdout)
    if input then
      last_insert_input = input
    end
    switch_to_default()
  end)
end

local function restore_last_insert_input()
  if restore_insert_input and last_insert_input ~= default_input then
    switch_to(last_insert_input)
  end
end

local group = vim.api.nvim_create_augroup("user_input_method", { clear = true })

vim.api.nvim_create_autocmd({ "VimEnter", "FocusGained" }, {
  group = group,
  callback = function()
    if vim.api.nvim_get_mode().mode ~= "i" then
      switch_to_default()
    end
  end,
})

vim.api.nvim_create_autocmd("InsertLeave", {
  group = group,
  callback = remember_insert_input_then_default,
})

vim.api.nvim_create_autocmd("InsertEnter", {
  group = group,
  callback = restore_last_insert_input,
})

vim.api.nvim_create_autocmd("CmdlineEnter", {
  group = group,
  callback = switch_to_default,
})

vim.api.nvim_create_user_command("InputMethodEnglish", switch_to_default, {})
vim.api.nvim_create_user_command("InputMethodRestore", restore_last_insert_input, {})
