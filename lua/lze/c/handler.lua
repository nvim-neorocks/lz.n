local M = {}

local handlers = require("lze.h")

---@param spec lze.PluginSpec
---@return boolean
function M.is_lazy(spec)
    ---@diagnostic disable-next-line: undefined-field
    return spec.lazy or vim.iter(handlers):any(function(hndl)
        return spec[hndl.spec_field] ~= nil
    end)
end

---@return lze.Handler[]
function M.clear_handlers()
    local old_handlers = handlers
    handlers = {}
    return old_handlers
end

---@param handler_list lze.Handler[]|lze.Handler|lze.HandlerSpec[]|lze.HandlerSpec
---@return string[]
function M.register_handlers(handler_list)
    assert(type(handler_list) == "table", "invalid argument to register_handlers")
    -- if single, make it a list anyway
    if handler_list.spec_field or handler_list.handler then
        handler_list = { handler_list }
    end
    local new_handlers = vim
        .iter(handler_list)
        -- normalize to handlerSpecs
        :map(function(spec)
            if spec.spec_field ~= nil then
                return { handler = spec }
            else
                return spec
            end
        end)
        -- filter our active, valid handlerSpecs
        :filter(function(spec)
            return spec.handler ~= nil
                and (
                    (spec.enabled == nil or spec.enabled == true)
                    or (type(spec.enabled) == "function" and spec.enabled())
                )
        end)
        -- normalize active handlers
        :map(function(spec)
            return spec.handler
        end)
        -- remove handlers already registered from list to add
        :filter(function(hndl)
            return vim.iter(handlers):all(function(hndlOG)
                return hndlOG.spec_field ~= hndl.spec_field
            end)
        end)
        :totable()

    -- remove internal duplicates
    local seen = {}
    local filtered_handlers = {}
    for _, item in ipairs(new_handlers) do
        if not seen[item] then
            seen[item] = true
            table.insert(filtered_handlers, item)
        end
    end

    vim.list_extend(handlers, filtered_handlers)
    return vim.iter(filtered_handlers)
        :map(function(hndl)
            return hndl.spec_field
        end)
        :totable()
end

---@param plugin lze.Plugin
local function enable(plugin)
    ---@param handler lze.Handler
    for _, handler in ipairs(handlers) do
        handler.add(plugin)
    end
end

function M.run_after(plugin)
    ---@param handler lze.Handler
    for _, handler in ipairs(handlers) do
        if handler.after then
            handler.after(plugin)
        end
    end
end

function M.run_before(plugin)
    ---@param handler lze.Handler
    for _, handler in ipairs(handlers) do
        if handler.before then
            handler.before(plugin)
        end
    end
end

---@param plugins table<string, lze.Plugin>
function M.init(plugins)
    ---@param plugin lze.Plugin
    for _, plugin in pairs(plugins) do
        xpcall(
            enable,
            vim.schedule_wrap(function(err)
                vim.notify(("Failed to enable handlers for %s: %s"):format(plugin.name, err), vim.log.levels.ERROR)
            end),
            plugin
        )
    end
end

return M
