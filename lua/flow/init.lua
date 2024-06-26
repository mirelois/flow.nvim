local extract = require('flow.extract')
local md = require('flow.markdown')
local cmd = require("flow.cmd")
local output = require("flow.output")
local sql = require("flow.sql")
local windows = require("flow.windows")
local vars = require("flow.vars")

local default_setup_options = {
    output = {
        buffer = false
    }
}

local setup_options = default_setup_options

local function run(filetype, code)
    local c = cmd.cmd(filetype, code)
    if c == nil then
        return
    end

    output.handle_output(c, setup_options.output)
end

local function handle_md_file(lines)
    local blocks = md.code_blocks_in_lines(lines)
    local block = md.select_block(blocks)

    if block == nil then
        print("flow: you are not on any code block")
        return
    end

    run(block.lang, block.code)
end

local function run_custom_cmd(suffix)
    if suffix == nil then
        print("flow: you need to provide an alias for the custom command (example: :RunCodeCustomCmd 1)")
        return
    end

    local c = cmd.custom_cmd(suffix)
    output.handle_output(c, setup_options.output)
end

local function run_last_custom_cmd()
    local c = cmd.get_last_custom_cmd()

    if c == nil then
        print("flow: you haven't run a custom command yet")
        return
    end

    output.handle_output(c, setup_options.output)
end

local function show_last_output()
    output.show_last_output(setup_options.output)
end

local function setup(options)
    setup_options = options

    cmd.override_cmd_map(options.filetype_cmd_map)
    cmd.override_custom_cmd_dir(options.custom_cmd_dir)
    sql.configs = options.sql_configs
end

return {
    run_custom_cmd = run_custom_cmd,
    run_last_custom_cmd = run_last_custom_cmd,
    show_last_output = show_last_output,
    setup = setup
}
