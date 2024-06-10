---@mod lz.n.loader

local state = require("lz.n.state")

local M = {}

local DEFAULT_PRIORITY = 50

---@package
---@param plugin lz.n.Plugin
function M._load(plugin)
    if plugin.enabled == false or (type(plugin.enabled) == "function" and not plugin.enabled()) then
        return
    end
    require("lz.n.handler").disable(plugin)
    ---@type fun(name: string) | nil
    local load_impl = vim.tbl_get(vim.g, "lz_n", "load")
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
        return (a.priority or DEFAULT_PRIORITY) > (b.priority or DEFAULT_PRIORITY)
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

---@param plugin lz.n.Plugin
local function config(plugin)
    if type(plugin.after) == "function" then
        xpcall(
            plugin.after,
            vim.schedule_wrap(function(err)
                vim.notify(
                    "Failed to run 'config' for " .. plugin.name .. ": " .. tostring(err or ""),
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
            M._load(plugin)
            config(plugin)
        end
    end
end

return M
