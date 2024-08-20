---@mod lze.loader

local state = require("lze.c.state")

local M = {}

local DEFAULT_PRIORITY = 50

---@package
---@param plugin lze.Plugin
function M._load(plugin)
    if plugin.enabled == false or (type(plugin.enabled) == "function" and not plugin.enabled()) then
        return
    end
    require("lze.c.handler").run_before(plugin)
    ---@type fun(name: string) | nil
    local load_impl = plugin.load or vim.tbl_get(vim.g, "lze", "load")
    if load_impl then
        load_impl(plugin.name)
    else
        vim.cmd.packadd(plugin.name)
    end
    require("lze.c.handler").run_after(plugin)
end

---@param plugins table<string, lze.Plugin>
local function run_before_all(plugins)
    ---@param plugin lze.Plugin
    for _, plugin in ipairs(plugins) do
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

---@param plugin lze.Plugin
local function get_priority(plugin)
    return plugin.priority or DEFAULT_PRIORITY
end

---@param plugins table<string, lze.Plugin>
---@return lze.Plugin[]
local function get_eager_plugins(plugins)
    ---@type lze.Plugin[]
    local result = vim
        .iter(plugins)
        ---@param plugin lze.Plugin
        :filter(function(_, plugin)
            return plugin.lazy ~= true
        end)
        :fold({}, function(acc, _, v)
            table.insert(acc, v)
            return acc
        end)
    table.sort(result, function(a, b)
        ---@cast a lze.Plugin
        ---@cast b lze.Plugin
        return get_priority(a) > get_priority(b)
    end)
    return result
end

--- Loads startup plugins, removing loaded plugins from the table
---@param plugins table<string, lze.Plugin>
function M.load_startup_plugins(plugins)
    run_before_all(plugins)
    ---@param plugin lze.Plugin
    for _, plugin in ipairs(get_eager_plugins(plugins)) do
        M.load(plugin.name)
    end
end

---@alias hook_key "before" | "after"

---@param hook_key hook_key
---@param plugin lze.Plugin
local function hook(hook_key, plugin)
    if plugin[hook_key] then
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

---@param plugin_names string | string[]
function M.load(plugin_names)
    plugin_names = (type(plugin_names) == "string") and { plugin_names } or plugin_names
    ---@cast plugin_names string[]
    for _, pname in pairs(plugin_names) do
        -- NOTE: do not make loading loops into vim.iter
        -- https://github.com/nvim-neorocks/lz.n/pull/21
        local loadable = true
        if state.plugins[pname] then
            if state.loaded[pname] then
                loadable = false
            else
                state.loaded[pname] = true
            end
        else
            if type(pname) ~= "string" then
                vim.notify(
                    "Plugin name invalid recieved " .. vim.inspect(pname),
                    vim.log.levels.ERROR,
                    { title = "lze" }
                )
            else
                vim.notify("Plugin " .. pname .. " not found", vim.log.levels.ERROR, { title = "lze" })
            end
            loadable = false
        end
        if loadable then
            local plugin = state.plugins[pname]
            hook("before", plugin)
            M._load(plugin)
            hook("after", plugin)
        end
    end
end

return M
