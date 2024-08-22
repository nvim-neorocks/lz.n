---@mod lz.n

local M = {}

if vim.fn.has("nvim-0.10.0") ~= 1 then
    error("lz.n requires Neovim >= 0.10.0")
end

local deferred_ui_enter = vim.schedule_wrap(function()
    if vim.v.exiting ~= vim.NIL then
        return
    end
    vim.g.lz_n_did_deferred_ui_enter = true
    vim.api.nvim_exec_autocmds("User", { pattern = "DeferredUIEnter", modeline = false })
end)

---@type fun(handler: lz.n.Handler): boolean
M.register_handler = function(...)
    return require("lz.n.handler").register_handler(...)
end

--- Accepts plugin names (`string | string[]`, when called in another
--- plugin's hook), or |lz.n.Plugin| items (when called by a |lz.n.Handler|).
--- If called with a plugin name, it will use the registered
--- handlers' `lookup` functions to search for a plugin to load
--- (loading the first one it finds).
--- Once a plugin has been loaded, it will be removed from all handlers (via `del`).
--- As a result, calling `trigger_load` with a plugin name is stateful and idempotent.
---@overload fun(plugins: lz.n.Plugin | string[] | lz.n.Plugin[] | table<unknown, lz.n.Plugin>)
---@overload fun(plugins: string | string[], opts: lz.n.lookup.Opts)
M.trigger_load = function(plugins, opts)
    require("lz.n.loader").load(plugins, function(name)
        return M.lookup(name, opts)
    end)
end

---@overload fun(spec: lz.n.Spec)
---@overload fun(import: string)
function M.load(spec)
    if type(spec) == "string" then
        spec = { import = spec }
    end
    --- @cast spec lz.n.Spec
    local spec_mod = require("lz.n.spec")
    local plugins = spec_mod.parse(spec)

    -- calls handler add functions
    require("lz.n.handler").init(plugins)

    -- Because this calls the handlers' `del` functions,
    -- this should be ran after the plugins are registered with the handlers.
    -- even if an eager plugin isn't supposed to have been added to any of them
    -- This allows even startup plugins to call
    -- `require('lz.n').trigger_load()` safely
    require("lz.n.loader").load_startup_plugins(plugins)

    if vim.v.vim_did_enter == 1 then
        deferred_ui_enter()
    elseif not vim.g.lz_n_did_create_deferred_ui_enter_autocmd then
        vim.api.nvim_create_autocmd("UIEnter", {
            once = true,
            callback = deferred_ui_enter,
        })
        vim.g.lz_n_did_create_deferred_ui_enter_autocmd = true
    end
end

--- Lookup a plugin that is pending to be loaded by name.
---@param name string
---@param opts? lz.n.lookup.Opts
---@return lz.n.Plugin?
function M.lookup(name, opts)
    return require("lz.n.handler").lookup(name, opts)
end

---@class lz.n.lookup.Opts
---
--- The handlers to include in the search (filtered by `spec_field`)
--- In case of multiple filters, the order of the filter list
--- determines the order in which handlers' `lookup` functions are called.
---@field filter string | string[]

return M
