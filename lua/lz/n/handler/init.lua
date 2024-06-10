---@class lz.n.Handler
---@field type lz.n.HandlerTypes
---@field pending table<string, table<string, string>> -- key: plugin_name: plugin_name
---@field add fun(plugin: lz.n.Plugin)
---@field del? fun(plugin: lz.n.Plugin)

local M = {}

---@enum lz.n.HandlerTypes
M.types = {
    cmd = "cmd",
    event = "event",
    ft = "ft",
    keys = "keys",
    colorscheme = "colorscheme",
}

local handlers = {
    cmd = require("lz.n.handler.cmd"),
    event = require("lz.n.handler.event"),
    ft = require("lz.n.handler.ft"),
    keys = require("lz.n.handler.keys"),
    colorscheme = require("lz.n.handler.colorscheme"),
}

---@param plugin lz.n.Plugin
local function enable(plugin)
    for _, handler in pairs(handlers) do
        handler.add(plugin)
    end
end

function M.disable(plugin)
    for _, handler in pairs(handlers) do
        if type(handler.del) == "function" then
            handler.del(plugin)
        end
    end
end

---@param plugins table<string, lz.n.Plugin>
function M.init(plugins)
    for _, plugin in pairs(plugins) do
        xpcall(
            enable,
            vim.schedule_wrap(function(err)
                vim.notify(("Failed to enable handlers for %s: %s"):format(plugin.name, err), vim.log.levels.ERROR)
            end),
            plugin
        )
    end
end

return M
