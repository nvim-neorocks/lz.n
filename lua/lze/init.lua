---@mod lze

local M = {}

if vim.fn.has("nvim-0.10.0") ~= 1 then
    error("lze requires Neovim >= 0.10.0")
end

local deferred_ui_enter = vim.schedule_wrap(function()
    if vim.v.exiting ~= vim.NIL then
        return
    end
    vim.g.lze_did_deferred_ui_enter = true
    vim.api.nvim_exec_autocmds("User", { pattern = "DeferredUIEnter", modeline = false })
end)

M.default_handlers = require("lze.h")

---THIS SHOULD BE CALLED BEFORE ANY CALLS TO lze.load ARE MADE
---Returns the cleared handlers
---@return lze.Handler[]
M.clear_handlers = require("lze.c.handler").clear_handlers

---THIS SHOULD BE CALLED BEFORE ANY CALLS TO lze.load ARE MADE
---Returns the list of spec_field values added.
---@type fun(handlers: lze.Handler[]|lze.Handler|lze.HandlerSpec[]|lze.HandlerSpec): string[]
M.register_handlers = require("lze.c.handler").register_handlers

---Trigger loading of the lze.Plugin loading hooks.
---Used by handlers to load plugins.
---@type fun(plugins: string| string[])
M.trigger_load = require("lze.c.loader").load

---May be called as many times as desired if passing it a single spec.
---Ideally should only be called on a big list of them once,
---as it does not exhaustively check for duplicates,
---and priority field only works within a single load call.
---@overload fun(spec: lze.Spec)
---@overload fun(import: string)
function M.load(spec)
    if spec == nil or spec == {} then
        return vim.schedule(function()
            vim.notify("load has been called, but no spec was provided", vim.log.levels.ERROR, { title = "lze" })
        end)
    end
    if type(spec) == "string" then
        spec = { import = spec }
    end
    --- @cast spec lze.Spec
    local plugins = require("lze.c.spec").parse(spec)

    -- add to state before loading anything, to prevent multiple loads being called
    -- from within other eager plugin specs
    local state = require("lze.c.state")
    local ok, updated_plugins = pcall(vim.tbl_deep_extend, "error", state.plugins, plugins)
    if not ok then
        return vim.schedule(function()
            vim.notify("Cannot load the same plugin specs more than once", vim.log.levels.ERROR, { title = "lze" })
        end)
    end
    state.plugins = updated_plugins

    -- calls handler add functions
    require("lze.c.handler").init(plugins)

    -- because this calls the handler's del functions,
    -- this should be ran after the handlers are given the plugin.
    -- even if the plugin isnt supposed to have been added to any of them
    require("lze.c.loader").load_startup_plugins(plugins)
    -- in addition, this allows even startup plugins to call
    -- require('lze').trigger_load('someplugin') safely

    if vim.v.vim_did_enter == 1 then
        deferred_ui_enter()
    elseif not vim.g.lze_did_create_deferred_ui_enter_autocmd then
        vim.api.nvim_create_autocmd("UIEnter", {
            once = true,
            callback = deferred_ui_enter,
        })
        vim.g.lze_did_create_deferred_ui_enter_autocmd = true
    end
end

---This function is HIGHLY inadviseable.
---however it might be useful in testing.
---Any issues using this function are not my fault.
---@type fun(plugins: string| string[])
M.force_load = function(plugins)
    plugins = (type(plugins) == "string") and { plugins } or plugins
    ---@cast plugins string[]
    local state = require("lze.c.state")
    for _, plugin in ipairs(plugins) do
        state.loaded[plugin] = nil
    end
    M.trigger_load(plugins)
end

return M
