---@type table<string, string[]|false>
local states = {}

-- NOTE: internal handlers must use internal trigger_load
-- because require('lze') requires this module.
local trigger_load = require("lze.c.loader").load

---@type lze.Handler
---@diagnostic disable-next-line: missing-fields
local M = {
    spec_field = "on_plugin",
}

---@param plugin lze.Plugin
function M.add(plugin)
    local on_plugin = plugin.on_plugin

    -- I dont know why I need to tell luacheck
    -- that I actually loop over it in like 10 lines from now
    ---@type string[]
    --luacheck: no unused
    local loaded_on = {}

    if type(on_plugin) == "table" then
        ---@cast on_plugin string[]
        loaded_on = on_plugin
    elseif type(on_plugin) == "string" then
        loaded_on = { on_plugin }
    else
        return
    end
    for _, name in ipairs(loaded_on) do
        if states[name] == false then
            trigger_load(plugin)
        else
            if states[name] == nil then
                states[name] = {}
            end
            vim.list_extend(states[name], { plugin.name })
        end
    end
end

---@param plugin lze.Plugin
function M.after(plugin)
    if states[plugin.name] ~= nil then
        trigger_load(states[plugin.name])
        states[plugin.name] = false
    end
end

return M
