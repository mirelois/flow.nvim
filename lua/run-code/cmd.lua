local vars = require('run-code.vars')

local DATA_DIR = vim.fn.stdpath("data")
local CUSTOM_CMD_FILE = DATA_DIR .. "/" .. "run_code_custom_cmd_%s"

local custom_command_filetype = 'bash'
local custom_command_default_split = '10split'
local custom_command_win = nil
local custom_command_buf = nil

local lang_cmd_map = {
  lua = "lua <<-EOF\n%s\nEOF",
  python = "python <<-EOF\n%s\nEOF",
  ruby = "ruby <<-EOF\n%s\nEOF",
  bash = "bash <<-EOF\n%s\nEOF",
  sh = "sh <<-EOF\n%s\nEOF",
  scheme = "scheme <<-EOF\n%s\nEOF",
  javascript = "node <<-EOF\n%s\nEOF",
  go = "go run ."
}

-- set_custom_cmd opens a small buffer that allows the user to edit the custom
-- command
local function set_custom_cmd(suffix)
  if suffix == nil then
    print("you need to provide an alias for the custom command (example: :RunCodeSetCustomCmd 1)")
    return
  end

  local file_name = string.format(CUSTOM_CMD_FILE, suffix)
  vim.cmd(custom_command_default_split .. ' ' .. file_name)
  custom_command_win = vim.api.nvim_get_current_win()
  custom_command_buf = vim.api.nvim_get_current_buf()
  vim.bo.filetype = custom_command_filetype
end

-- callback function that gets triggered when the command is saved
local function close_custom_cmd_win()
  if custom_command_win ~= nil then
    vim.api.nvim_win_close(custom_command_win, false)
    custom_command_win = nil
  end

  if custom_command_buf ~= nil then
    vim.api.nvim_buf_delete(custom_command_buf, {})
    custom_command_buf = nil
  end
end

-- constructs a command in the following format:
--
-- <binary to run> <output_file> <<-EOF
--    <code>
-- EOF
--
local function cmd(lang, code)
  local cmd_tmpl = lang_cmd_map[lang]
  if cmd_tmpl == nil then
    return ""
  end

  return string.format(cmd_tmpl, code)
end

local function custom_cmd(suffix)
  local file_name = string.format(CUSTOM_CMD_FILE, suffix)
  local custom_cmd_file = io.open(file_name, "r")
  local cmd_str = ""

  if custom_cmd_file ~= nil then
    cmd_str = custom_cmd_file:read("a")
    io.close(custom_cmd_file)
  end

  return vars.vars_to_export() .. "; " .. cmd_str
end

local function get_custom_cmds()
  local ls = vim.fn.system(string.format("ls " .. CUSTOM_CMD_FILE, "*"))
  local cmds = {}
  for s in ls:gmatch("run_code_custom_cmd_(%g+)") do
    table.insert(cmds, s)
  end
  return cmds
end

local function delete_custom_cmd(suffix)
  local file_name = string.format(CUSTOM_CMD_FILE, suffix)
  os.remove(file_name)
end

return {
  cmd = cmd,
  custom_cmd = custom_cmd,
  set_custom_cmd = set_custom_cmd,
  close_custom_cmd_win = close_custom_cmd_win,
  get_custom_cmds = get_custom_cmds,
  delete_custom_cmd = delete_custom_cmd
}
