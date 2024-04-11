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

---@param lz_event LzEvent
function M.add(lz_event)
  event.add(lz_event)
end

return M
