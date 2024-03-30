local vars = require('flow.vars')
local sql = require('flow.sql')
local windows = require('flow.windows')

local DATA_DIR = vim.fn.stdpath("data")
local CUSTOM_CMD_FILE = DATA_DIR .. "/" .. "run_code_custom_cmd_%s"

local custom_command_filetype = 'bash'
local custom_command_default_split = '10split'
local custom_command_win = nil
local custom_command_buf = nil
local last_custom_cmd = nil

-- set_custom_cmd opens a small buffer that allows the user to edit the custom
-- command
local function set_custom_cmd(suffix)
    if suffix == nil then
        print("flow: you need to provide an alias for the custom command (example: :FlowSetCustomCmd 1)")
        return
    end

    local file_name = string.format(CUSTOM_CMD_FILE, suffix)
    windows.open_custom_cmd_window(file_name, custom_command_filetype)
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

local function custom_cmd(suffix)
    local file_name = string.format(CUSTOM_CMD_FILE, suffix)
    local custom_cmd_file = io.open(file_name, "r")
    local cmd_str = ""

    if custom_cmd_file ~= nil then
        cmd_str = custom_cmd_file:read("a")
        io.close(custom_cmd_file)
    end

    local cmd_with_vars = vars.vars_to_export() .. "; " .. cmd_str
    last_custom_cmd = cmd_with_vars
    return cmd_with_vars
end

local function get_custom_cmds()
    local ls = vim.fn.system(string.format("ls " .. CUSTOM_CMD_FILE, "*"))
    local cmds = {}
    for s in ls:gmatch("run_code_custom_cmd_([^\n]+)") do
        table.insert(cmds, s)
    end
    return cmds
end

local function delete_custom_cmd(suffix)
    local file_name = string.format(CUSTOM_CMD_FILE, suffix)
    os.remove(file_name)
    print(string.format("flow: deleted custom command '%s'", suffix))
end

local function get_last_custom_cmd()
    return last_custom_cmd
end

local function override_custom_cmd_dir(dir)
    if dir == nil then
        return
    end

    -- make sure the directory exists
    vim.fn.system(string.format("mkdir -p %s", dir))

    DATA_DIR = dir
    CUSTOM_CMD_FILE = dir .. "/" .. "run_code_custom_cmd_%s"
end

return {
    custom_cmd = custom_cmd,
    set_custom_cmd = set_custom_cmd,
    close_custom_cmd_win = close_custom_cmd_win,
    get_custom_cmds = get_custom_cmds,
    get_last_custom_cmd = get_last_custom_cmd,
    delete_custom_cmd = delete_custom_cmd,
    override_custom_cmd_dir = override_custom_cmd_dir,
}
