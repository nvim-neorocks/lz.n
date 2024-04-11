---@mod lz.n.loader

local state = require('lz.n.state')

local M = {}

local DEFAULT_PRIORITY = 50

---@package
---@param plugin LzPlugin
function M._load(plugin)
  if plugin.enable == false or (type(plugin.enable) == 'function' and not plugin.enable()) then
    return
  end
  require('lz.n.handler').disable(plugin)
  -- TODO: Load plugin
end

---@param plugins table<string, LzPlugin>
local function run_before_all(plugins)
  for _, plugin in pairs(plugins) do
    if plugin.beforeAll then
      xpcall(
        plugin.beforeAll,
        vim.schedule_wrap(function(err)
          vim.notify(
            "Failed to run 'beforeAll' for " .. plugin.name .. ': ' .. tostring(err or ''),
            vim.log.levels.ERROR
          )
        end),
        plugin
      )
    end
  end
end

---@param plugins table<string, LzPlugin>
---@return LzPlugin[]
local function get_eager_plugins(plugins)
  local result = {}
  for _, plugin in pairs(plugins) do
    if plugin.lazy == false then
      table.insert(result, plugin)
    end
  end
  table.sort(result, function(a, b)
    ---@cast a LzPlugin
    ---@cast b LzPlugin
    return (a.priority or DEFAULT_PRIORITY) > (b.priority or DEFAULT_PRIORITY)
  end)
  return result
end

--- Loads startup plugins, removing loaded plugins from the table
---@param plugins table<string, LzPlugin>
function M.load_startup_plugins(plugins)
  run_before_all(plugins)
  for _, plugin in pairs(get_eager_plugins(plugins)) do
    M.load(plugin)
    plugins[plugin.name] = nil
  end
end

---@param plugins string | LzPlugin | string[] | LzPlugin[]
function M.load(plugins)
  plugins = (type(plugins) == 'string' or plugins.name) and { plugins } or plugins
  ---@cast plugins (string|LzPlugin)[]
  for _, plugin in pairs(plugins) do
    local loadable = true
    if type(plugin) == 'string' then
      if state.plugins[plugin] then
        plugin = state.plugins[plugin]
      else
        vim.notify('Plugin ' .. plugin .. ' not found', vim.log.levels.ERROR, { title = 'lz.n' })
        loadable = false
      end
      ---@cast plugin LzPlugin
    end
    if loadable then
      M._load(plugin)
    end
  end
end

return M
