local loader = require("lz.n.loader")

---@class lz.n.ColorschemeHandler: lz.n.Handler
---@field augroup? integer

---@type lz.n.ColorschemeHandler
local M = {
    ---@type table<string, table<string, lz.n.Plugin[]>>
    pending = {},
    augroup = nil,
    spec_field = "colorscheme",
}

---@param name string
---@return lz.n.Plugin?
function M.lookup(name)
    return require("lz.n.handler.extra").lookup(M.pending, name)
end

---@param plugin lz.n.Plugin
function M.del(plugin)
    vim.iter(M.pending):each(function(_, plugins)
        plugins[plugin.name] = nil
    end)
end

---@param name string
local function on_colorscheme(name)
    local pending = M.pending[name] or {}
    if vim.tbl_isempty(pending) then
        -- already loaded
        return
    end
    loader.load(vim.tbl_values(pending))
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
        M.pending[colorscheme] = M.pending[colorscheme] or {}
        M.pending[colorscheme][plugin.name] = plugin
    end)
end

return M
