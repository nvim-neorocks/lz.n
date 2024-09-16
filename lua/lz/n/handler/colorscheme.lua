local loader = require("lz.n.loader")

---@class lz.n.ColorschemeHandler: lz.n.Handler
---@field augroup? integer

---@type lz.n.handler.State
local state = require("lz.n.handler.state").new()

---@type lz.n.ColorschemeHandler
local M = {
    augroup = nil,
    spec_field = "colorscheme",
    ---@param colorscheme_spec? string[]|string
    parse = function(plugin, colorscheme_spec)
        if colorscheme_spec then
            plugin.colorscheme = {}
        end
        if type(colorscheme_spec) == "string" then
            table.insert(plugin.colorscheme, colorscheme_spec)
        elseif type(colorscheme_spec) == "table" then
            ---@param colorscheme_spec_ string
            vim.iter(colorscheme_spec):each(function(colorscheme_spec_)
                table.insert(plugin.colorscheme, colorscheme_spec_)
            end)
        end
    end,
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
        nested = true,
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
