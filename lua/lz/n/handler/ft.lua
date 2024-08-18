local event = require("lz.n.handler.event")

---@class lz.n.FtHandler: lz.n.Handler
---@field parse fun(spec: lz.n.EventSpec): lz.n.Event

---@type lz.n.FtHandler
local M = {
    spec_field = "ft",
    ---@param value string
    ---@return lz.n.Event
    parse = function(value)
        return {
            id = value,
            event = "FileType",
            pattern = value,
        }
    end,
    lookup = event.lookup,
}

---@param plugin lz.n.Plugin
function M.add(plugin)
    event.add(plugin)
end

---@param plugin lz.n.Plugin
function M.del(plugin)
    event.del(plugin)
end

return M
