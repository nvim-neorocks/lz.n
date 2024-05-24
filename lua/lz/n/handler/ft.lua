local event = require('lz.n.handler.event')

---@class LzFtHandler: LzHandler

---@type LzFtHandler
local M = {
  active = {},
  managed = {},
  type = 'ft',
}

---@param value string
---@return LzEvent
function M.parse(value)
  return {
    id = value,
    event = 'FileType',
    pattern = value,
  }
end

---@param plugin LzPlugin
function M.add(plugin)
  event.add(plugin)
end

return M
