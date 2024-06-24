local loader = require("lz.n.loader")

---@class lz.n.ColorschemeHandler: lz.n.Handler
---@field augroup? integer

---@type lz.n.ColorschemeHandler
local M = {
    pending = {},
    augroup = nil,
    spec_field = "colorscheme",
}

---@param plugin lz.n.Plugin
function M.del(plugin)
    for _, plugins in pairs(M.pending) do
        plugins[plugin.name] = nil
    end
end

---@param name string
local function on_colorscheme(name)
    if vim.tbl_contains(vim.fn.getcompletion("", "color"), name) then
        return
    end
    loader.load(vim.tbl_values(M.pending[name]))
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
    for _, colorscheme in pairs(plugin.colorscheme) do
        M.pending[colorscheme] = M.pending[colorscheme] or {}
        M.pending[colorscheme][plugin.name] = plugin.name
    end
end

return M
