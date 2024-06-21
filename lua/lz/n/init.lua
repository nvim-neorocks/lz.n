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
M.register_handler = require("lz.n.handler").register_handler

---@type fun(plugins: string | lz.n.Plugin | string[] | lz.n.Plugin[])
M.trigger_load = require("lz.n.loader").load

---@overload fun(spec: lz.n.Spec)
---@overload fun(import: string)
function M.load(spec)
    if type(spec) == "string" then
        spec = { import = spec }
    end
    --- @cast spec lz.n.Spec
    local spec_mod = require("lz.n.spec")
    local is_single_plugin_spec = spec_mod.is_single_plugin_spec(spec)
    local plugins = spec_mod.parse(spec)
    require("lz.n.loader").load_startup_plugins(plugins)

    local state = require("lz.n.state")
    if is_single_plugin_spec then
        local ok, updated_plugins = pcall(vim.tbl_deep_extend, "error", state.plugins, plugins)
        if not ok then
            return vim.schedule(function()
                vim.notify("Cannot load the same plugin specs more than once", vim.log.levels.ERROR, { title = "lz.n" })
            end)
        end
        state.plugins = updated_plugins
    else
        if state.plugins[spec[1]] then
            return vim.schedule(function()
                vim.notify(
                    ("Plugin %s has already been registered for lazy loading"):format(spec[1]),
                    vim.log.levels.ERROR,
                    { title = "lz.n" }
                )
            end)
        end
        state.plugins = plugins
    end
    require("lz.n.handler").init(plugins)
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

return M
