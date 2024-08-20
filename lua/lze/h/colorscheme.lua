-- NOTE: internal handlers must use internal trigger_load
-- because require('lze') requires this module.
local loader = require("lze.c.loader")

---@class lze.ColorschemeHandler: lze.Handler
---@field augroup? integer

---@type lze.ColorschemeHandler
local M = {
    pending = {},
    augroup = nil,
    spec_field = "colorscheme",
}

---@param plugin lze.Plugin
function M.before(plugin)
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
    M.augroup = vim.api.nvim_create_augroup("lze_handler_colorscheme", { clear = true })
    vim.api.nvim_create_autocmd("ColorSchemePre", {
        callback = function(event)
            on_colorscheme(event.match)
        end,
        group = M.augroup,
    })
end

---@param plugin lze.Plugin
function M.add(plugin)
    local colorscheme_spec = plugin.colorscheme
    if not colorscheme_spec then
        return
    end
    local colorscheme_def = {}
    if type(colorscheme_spec) == "string" then
        table.insert(colorscheme_def, colorscheme_spec)
    elseif type(colorscheme_spec) == "table" then
        ---@param colorscheme_spec_ string
        vim.iter(colorscheme_spec):each(function(colorscheme_spec_)
            table.insert(colorscheme_def, colorscheme_spec_)
        end)
    end
    -- DIRTY HACK DO NOT REPLICATE

    -- add is called after state is updated

    -- add is called before ANY loading code.

    -- lze does not allow handlers to provide
    -- plugin specs to trigger_load to be ran unmodified,
    -- so state is actually authoritative in lze

    require("lze.c.state").plugins[plugin.name].priority = 1000
    -- will throw an error if this doesnt work. It always should.

    init()
    ---@param colorscheme string
    vim.iter(colorscheme_def):each(function(colorscheme)
        M.pending[colorscheme] = M.pending[colorscheme] or {}
        M.pending[colorscheme][plugin.name] = plugin.name
    end)
end

return M
