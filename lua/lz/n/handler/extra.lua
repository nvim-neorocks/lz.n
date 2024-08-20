---@mod lz.n.handler.extra Helper functions for use by handlers

local M = {}

---Look up a plugin in a plugin table, commonly used by handlers to
---keep track of plugins they manage
---@param plugin_tbl table<unknown, table<string, lz.n.Plugin>>
---@param name string
---@return lz.n.Plugin?
function M.lookup(plugin_tbl, name)
    return vim
        .iter(plugin_tbl)
        ---@param plugins table<string, lz.n.Plugin>
        :map(function(_, plugins)
            return plugins[name]
        end)
        ---@param plugin lz.n.Plugin?
        :find(function(plugin)
            return plugin ~= nil
        end)
end

return M
