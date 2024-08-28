local loader = require("lz.n.loader")

---@class lz.n.ColorschemeHandler: lz.n.Handler
---@field augroup? integer

---@type lz.n.handler.State
local state = require("lz.n.handler.state").new()

---@type lz.n.ColorschemeHandler
local M = {
    augroup = nil,
    spec_field = "colorscheme",
}

---@param name string
---@return lz.n.Plugin?
function M.lookup(name)
    return state.lookup_plugin(name)
end

M.del = state.del

---@param name string
local function on_colorscheme(name)
    state.each_pending(name, loader.load)
end

local function init()
    if M.augroup then
        return
    end
    M.augroup = vim.api.nvim_create_augroup("lz_n_handler_colorscheme", { clear = true })
    vim.api.nvim_create_autocmd("ColorSchemePre", {
        callback = function(event)
            on_colorscheme(event.match)
        end,
        group = M.augroup,
    })
end

---@param plugin lz.n.Plugin
function M.add(plugin)
    if not plugin.colorscheme then
        return
    end
    init()
    ---@param colorscheme string
    vim.iter(plugin.colorscheme):each(function(colorscheme)
        state.insert(colorscheme, plugin)
    end)
end

return M
