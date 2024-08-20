-- NOTE: internal handlers must use internal trigger_load
-- because require('lze') requires this module.
local loader = require("lze.c.loader")

---@class lze.CmdHandler: lze.Handler

---@type lze.CmdHandler
local M = {
    pending = {},
    spec_field = "cmd",
}

---@param cmd string
local function load(cmd)
    vim.api.nvim_del_user_command(cmd)
    loader.load(vim.tbl_values(M.pending[cmd]))
end

---@param cmd string
local function add_cmd(cmd)
    vim.api.nvim_create_user_command(cmd, function(event)
        ---@cast event vim.api.keyset.user_command
        local command = {
            cmd = cmd,
            bang = event.bang or nil,
            ---@diagnostic disable-next-line: undefined-field
            mods = event.smods,
            ---@diagnostic disable-next-line: undefined-field
            args = event.fargs,
            count = event.count >= 0 and event.range == 0 and event.count or nil,
        }

        if event.range == 1 then
            ---@diagnostic disable-next-line: undefined-field
            command.range = { event.line1 }
        elseif event.range == 2 then
            ---@diagnostic disable-next-line: undefined-field
            command.range = { event.line1, event.line2 }
        end

        load(cmd)

        local info = vim.api.nvim_get_commands({})[cmd] or vim.api.nvim_buf_get_commands(0, {})[cmd]
        if not info then
            vim.schedule(function()
                ---@type string
                local plugins = "`" .. table.concat(vim.tbl_values(M.pending[cmd]), ", ") .. "`"
                vim.notify("Command `" .. cmd .. "` not found after loading " .. plugins, vim.log.levels.ERROR)
            end)
            return
        end

        command.nargs = info.nargs
        ---@diagnostic disable-next-line: undefined-field
        if event.args and event.args ~= "" and info.nargs and info.nargs:find("[1?]") then
            ---@diagnostic disable-next-line: undefined-field
            command.args = { event.args }
        end
        vim.cmd(command)
    end, {
        bang = true,
        range = true,
        nargs = "*",
        complete = function(_, line)
            load(cmd)
            return vim.fn.getcompletion(line, "cmdline")
        end,
    })
end

---@param plugin lze.Plugin
function M.before(plugin)
    pcall(vim.api.nvim_del_user_command, plugin.cmd)
    vim.iter(M.pending):each(function(_, plugins)
        plugins[plugin.name] = nil
    end)
end

---@param plugin lze.Plugin
function M.add(plugin)
    local cmd_spec = plugin.cmd
    if not cmd_spec then
        return
    end
    local cmd_def = {}
    if type(cmd_spec) == "string" then
        table.insert(cmd_def, cmd_spec)
    elseif type(cmd_spec) == "table" then
        ---@param cmd_spec_ string
        vim.iter(cmd_spec):each(function(cmd_spec_)
            table.insert(cmd_def, cmd_spec_)
        end)
    end
    ---@param cmd string
    vim.iter(cmd_def):each(function(cmd)
        M.pending[cmd] = M.pending[cmd] or {}
        M.pending[cmd][plugin.name] = plugin.name
        add_cmd(cmd)
    end)
end

return M
