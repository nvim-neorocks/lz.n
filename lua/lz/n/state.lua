---@mod lz.n.state

local M = {}

---@type table<string, lz.n.Plugin>
M.plugins = {}

---@type table<string, true>
M.loaded = {}

return M
