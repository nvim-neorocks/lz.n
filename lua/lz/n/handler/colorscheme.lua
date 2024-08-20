local loader = require("lz.n.loader")

---@class lz.n.ColorschemeHandler: lz.n.Handler
---@field augroup? integer

local pending = {}

---@type lz.n.ColorschemeHandler
local M = {
    ---@type table<string, table<string, lz.n.Plugin[]>>
    augroup = nil,
    spec_field = "colorscheme",
}

---@param name string
---@return lz.n.Plugin?
function M.lookup(name)
    return require("lz.n.handler.extra").lookup(pending, name)
end

---@param name string
function M.del(name)
    vim.iter(pending):each(function(_, plugins)
        plugins[name] = nil
    end)
end

---@param name string
local function on_colorscheme(name)
    local plugins = pending[name] or {}
    if vim.tbl_isempty(plugins) then
        -- already loaded
        return
    end
    loader.load(vim.tbl_values(plugins))
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
        pending[colorscheme] = pending[colorscheme] or {}
        pending[colorscheme][plugin.name] = plugin
    end)
end

return M
