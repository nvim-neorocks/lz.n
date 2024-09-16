local loader = require("lz.n.loader")

---@class lz.n.CmdHandler: lz.n.Handler

---@type lz.n.handler.State
local state = require("lz.n.handler.state").new()

---@type lz.n.CmdHandler
local M = {
    spec_field = "cmd",
    ---@param cmd_spec? string[]|string
    parse = function(result, cmd_spec)
        if cmd_spec then
            result.cmd = {}
        end
        if type(cmd_spec) == "string" then
            table.insert(result.cmd, cmd_spec)
        elseif type(cmd_spec) == "table" then
            ---@param cmd_spec_ string
            vim.iter(cmd_spec):each(function(cmd_spec_)
                table.insert(result.cmd, cmd_spec_)
            end)
        end
    end,
}

---@param name string
---@return lz.n.Plugin?
function M.lookup(name)
    return state.lookup_plugin(name)
end

---@param cmd string
---@return string[] loaded_plugin_names
local function load(cmd)
    vim.api.nvim_del_user_command(cmd)
    ---@diagnostic disable-next-line: return-type-mismatch
    return state.each_pending(cmd, loader.load)
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

        local plugin_names = load(cmd)

        local info = vim.api.nvim_get_commands({})[cmd] or vim.api.nvim_buf_get_commands(0, {})[cmd]
        if not info then
            vim.schedule(function()
                ---@type string
                local plugins_str = "`" .. table.concat(plugin_names, ", ") .. "`"
                vim.notify("Command `" .. cmd .. "` not found after loading " .. plugins_str, vim.log.levels.ERROR)
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

---@param name string
function M.del(name)
    state.del(name, function(cmd)
        pcall(vim.api.nvim_del_user_command, cmd)
    end)
end

---@param plugin lz.n.Plugin
function M.add(plugin)
    if not plugin.cmd then
        return
    end
    ---@param cmd string
    vim.iter(plugin.cmd):each(function(cmd)
        state.insert(cmd, plugin)
        add_cmd(cmd)
    end)
end

return M
