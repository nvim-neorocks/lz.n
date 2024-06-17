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

---@overload fun(spec: lz.n.Spec)
---@overload fun(import: string)
function M.load(spec)
    if type(spec) == "string" then
        spec = { import = spec }
    end
    --- @cast spec lz.n.Spec
    local spec_mod = require("lz.n.spec")
    local is_single_plugin_spec = spec_mod.is_single_plugin_spec(spec)
    if not is_single_plugin_spec then
        if vim.g.lz_n_did_load then
            return vim.notify(
                "lz.n.load() should only be called on a list of plugin specs once.",
                vim.log.levels.WARN,
                { title = "lz.n" }
            )
        end
        vim.g.lz_n_did_load = true
    end
    local plugins = spec_mod.parse(spec)
    require("lz.n.loader").load_startup_plugins(plugins)

    local state = require("lz.n.state")
    if is_single_plugin_spec then
        state.plugins = vim.tbl_deep_extend("force", state.plugins, plugins)
    else
        if state.plugins[spec[1]] then
            return vim.notify(
                ("Plugin %s has already been registered for lazy loading"):format(spec[1]),
                vim.log.levels.WARN,
                { title = "lz.n" }
            )
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
