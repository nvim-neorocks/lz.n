---@class LzHandler
---@field type LzHandlerTypes
---@field active table<string,table<string,string>>
---@field managed table<string,string>
---@field add fun(plugin: LzPlugin)
---@field del? fun(plugin: LzPlugin)

local M = {}

---@enum LzHandlerTypes
M.types = {
  cmd = 'cmd',
  event = 'event',
  ft = 'ft',
  keys = 'keys',
}

local handlers = {
  cmd = require('lz.n.handler.cmd'),
  event = require('lz.n.handler.event'),
  ft = require('lz.n.handler.ft'),
  keys = require('lz.n.handler.keys'),
}

---@param plugin LzPlugin
local function enable(plugin)
  for _, handler in pairs(handlers) do
    handler.add(plugin)
  end
  -- TODO: Change handler add implementations to take a LzPlugin
end

function M.disable(plugin)
  for _, handler in pairs(handlers) do
    if type(handler.del) == 'function' then
      -- TODO: Change handler del implementations to take a LzPlugin?
      handler.del(plugin)
    end
  end
end

---@param plugins table<string, LzPlugin>
function M.init(plugins)
  for _, plugin in pairs(plugins) do
    xpcall(
      enable,
      vim.schedule_wrap(function(err)
        vim.notify(('Failed to enable handlers for %s: %s'):format(plugin.name, err), vim.log.levels.ERROR)
      end),
      plugin
    )
  end
end

return M
