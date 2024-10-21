---A handler for plugins that have `lazy` set to true without any other lazy-loading mechanisms configured.
---@class lz.n.LazyHandler: lz.n.Handler

---@type lz.n.handler.State
local state = require("lz.n.handler.state").new()

local M = {
    spec_field = "lazy",
}

---@param name string
---@return lz.n.Plugin?
function M.lookup(name)
    return state.lookup_plugin(name)
end

---@param name string
function M.del(name)
    state.del(name, function(cmd)
        pcall(vim.api.nvim_del_user_command, cmd)
    end)
end

---@param plugin lz.n.Plugin
function M.add(plugin)
    if not plugin.lazy then
        return
    end
    state.insert(plugin)
end

return M
