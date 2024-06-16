---@mod lz.n.loader

local state = require("lz.n.state")

local M = {}

local DEFAULT_PRIORITY = 50

local DEFAULT_COLORSCHEME_PRIORITY = 1000

---@package
---@param plugin lz.n.Plugin
function M._load(plugin)
    if plugin.enabled == false or (type(plugin.enabled) == "function" and not plugin.enabled()) then
        return
    end
    require("lz.n.handler").disable(plugin)
    ---@type fun(name: string) | nil
    local load_impl = plugin.load or vim.tbl_get(vim.g, "lz_n", "load")
    if type(load_impl) == "function" then
        load_impl(plugin.name)
    else
        vim.cmd.packadd(plugin.name)
    end
end

---@param plugins table<string, lz.n.Plugin>
local function run_before_all(plugins)
    for _, plugin in pairs(plugins) do
        if plugin.beforeAll then
            xpcall(
                plugin.beforeAll,
                vim.schedule_wrap(function(err)
                    vim.notify(
                        "Failed to run 'beforeAll' for " .. plugin.name .. ": " .. tostring(err or ""),
                        vim.log.levels.ERROR
                    )
                end),
                plugin
            )
        end
    end
end

---@param plugin lz.n.Plugin
local function get_priority(plugin)
    return plugin.priority or (plugin.colorscheme and DEFAULT_COLORSCHEME_PRIORITY) or DEFAULT_PRIORITY
end

---@param plugins table<string, lz.n.Plugin>
---@return lz.n.Plugin[]
local function get_eager_plugins(plugins)
    local result = {}
    for _, plugin in pairs(plugins) do
        if plugin.lazy == false then
            table.insert(result, plugin)
        end
    end
    table.sort(result, function(a, b)
        ---@cast a lz.n.Plugin
        ---@cast b lz.n.Plugin
        return get_priority(a) > get_priority(b)
    end)
    return result
end

--- Loads startup plugins, removing loaded plugins from the table
---@param plugins table<string, lz.n.Plugin>
function M.load_startup_plugins(plugins)
    run_before_all(plugins)
    for _, plugin in pairs(get_eager_plugins(plugins)) do
        M.load(plugin)
        plugins[plugin.name] = nil
    end
end

---@alias hook_key "before" | "after"

---@param hook_key hook_key
---@param plugin lz.n.Plugin
local function hook(hook_key, plugin)
    if type(plugin[hook_key]) == "function" then
        xpcall(
            plugin[hook_key],
            vim.schedule_wrap(function(err)
                vim.notify(
                    "Failed to run '" .. hook_key .. "' hook for " .. plugin.name .. ": " .. tostring(err or ""),
                    vim.log.levels.ERROR
                )
            end),
            plugin
        )
    end
end

---@param plugins string | lz.n.Plugin | string[] | lz.n.Plugin[]
function M.load(plugins)
    plugins = (type(plugins) == "string" or plugins.name) and { plugins } or plugins
    ---@cast plugins (string|lz.n.Plugin)[]
    for _, plugin in pairs(plugins) do
        local loadable = true
        if type(plugin) == "string" then
            if state.plugins[plugin] then
                plugin = state.plugins[plugin]
            else
                vim.notify("Plugin " .. plugin .. " not found", vim.log.levels.ERROR, { title = "lz.n" })
                loadable = false
            end
            ---@cast plugin lz.n.Plugin
        end
        if loadable then
            hook("before", plugin)
            M._load(plugin)
            hook("after", plugin)
        end
    end
end

return M
