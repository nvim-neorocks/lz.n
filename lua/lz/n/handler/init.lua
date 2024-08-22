local M = {}

local handlers = {
    cmd = require("lz.n.handler.cmd"),
    event = require("lz.n.handler.event"),
    ft = require("lz.n.handler.ft"),
    keys = require("lz.n.handler.keys"),
    colorscheme = require("lz.n.handler.colorscheme"),
}

---@param name string
---@param opts? lz.n.lookup.Opts
---@return lz.n.Plugin?
function M.lookup(name, opts)
    ---@type string | string[] | nil
    local filter = opts and vim.tbl_get(opts, "filter")
    if type(filter) == "string" then
        filter = { filter }
    end
    ---@type lz.n.Handler[]
    local handler_list = filter
            and vim.iter(filter)
                :map(function(key)
                    return handlers[key]
                end)
                :totable()
        or vim.tbl_values(handlers)
    ---@cast filter string[] | nil
    return vim
        .iter(handler_list)
        ---@param handler lz.n.Handler
        :map(function(handler)
            return handler.lookup(name)
        end)
        ---@param result lz.n.Plugin?
        :find(function(result)
            return result ~= nil
        end)
end

---@param spec lz.n.PluginSpec
---@return boolean
function M.is_lazy(spec)
    ---@diagnostic disable-next-line: undefined-field
    return spec.lazy or vim.iter(handlers):any(function(spec_field, _)
        return spec[spec_field] ~= nil
    end)
end

---@param handler lz.n.Handler
---@return boolean success
function M.register_handler(handler)
    if not handler.lookup then
        vim.schedule(function()
            vim.notify(
                ([[
lz.n: handler for %s does not have a 'lookup' function.
Ignoring.
]]):format(handler.spec_field),
                vim.log.levels.WARN
            )
        end)
        return false
    end
    if not handler.del then
        vim.schedule(function()
            vim.notify(
                ([[
lz.n: handler for %s does not have a 'del' function.
Ignoring.
]]):format(handler.spec_field),
                vim.log.levels.WARN
            )
        end)
        return false
    end
    if handlers[handler.spec_field] == nil then
        handlers[handler.spec_field] = handler
        return true
    else
        vim.notify(
            "Handler already exists for " .. handler.spec_field .. ". Refusing to register new handler.",
            vim.log.levels.ERROR,
            { title = "lz.n" }
        )
        return false
    end
end

---@param plugin lz.n.Plugin
local function enable(plugin)
    ---@param handler lz.n.Handler
    vim.iter(handlers):each(function(_, handler)
        handler.add(plugin)
    end)
end

---@param name string
function M.disable(name)
    ---@param handler lz.n.Handler
    vim.iter(handlers):each(function(_, handler)
        handler.del(name)
    end)
end

---@param plugins table<string, lz.n.Plugin>
function M.init(plugins)
    ---@param plugin lz.n.Plugin
    vim.iter(plugins):each(function(_, plugin)
        xpcall(
            enable,
            vim.schedule_wrap(function(err)
                vim.notify(("Failed to enable handlers for %s: %s"):format(plugin.name, err), vim.log.levels.ERROR)
            end),
            plugin
        )
    end)
end

return M
