local event = require("lz.n.handler.event")

---@class LzFtHandler: LzHandler
---@field parse fun(spec: LzEventSpec): LzEvent

---@type LzFtHandler
local M = {
    pending = {},
    type = "ft",
    ---@param value string
    ---@return LzEvent
    parse = function(value)
        return {
            id = value,
            event = "FileType",
            pattern = value,
        }
    end,
}

---@param plugin LzPlugin
function M.add(plugin)
    event.add(plugin)
end

return M
