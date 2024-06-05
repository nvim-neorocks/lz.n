local M = {}

---@param spec LzSpecImport
---@param result table<string, LzPlugin>
local function import_spec(spec, result)
    if spec.import == "lz.n" then
        vim.schedule(function()
            vim.notify("Plugins modules cannot be called 'lz.n'", vim.log.levels.ERROR)
        end)
        return
    end
    if type(spec.import) ~= "string" then
        vim.schedule(function()
            vim.notify(
                "Invalid import spec. The 'import' field should be a module name: " .. vim.inspect(spec),
                vim.log.levels.ERROR
            )
        end)
        return
    end
    if spec.cond == false or (type(spec.cond) == "function" and not spec.cond()) then
        return
    end
    if spec.enabled == false or (type(spec.enabled) == "function" and not spec.enabled()) then
        return
    end
    local modname = "plugin." .. spec.import
    local ok, mod = pcall(require, modname)
    if not ok then
        vim.schedule(function()
            local err = type(mod) == "string" and ": " .. mod or ""
            vim.notify("Failed to load module '" .. modname .. err, vim.log.levels.ERROR)
        end)
        return
    end
    if type(mod) ~= table then
        vim.schedule(function()
            vim.notify(
                "Invalid plugin spec module '" .. modname .. "' of type '" .. type(mod) .. "'",
                vim.log.levels.ERROR
            )
        end)
        return
    end
    M._normalize(mod, result)
end

---@param spec LzPluginSpec
---@return LzPlugin
local function parse(spec)
    ---@type LzPlugin
    ---@diagnostic disable-next-line: assign-type-mismatch
    local result = vim.deepcopy(spec)
    local event_spec = spec.event
    if event_spec then
        result.event = {}
    end
    if type(event_spec) == "string" then
        local event = require("lz.n.handler.event").parse(event_spec)
        result.event[event.id] = event
    elseif type(event_spec) == "table" then
        ---@cast event_spec LzEventSpec[]
        for _, _event_spec in pairs(event_spec) do
            local event = require("lz.n.handler.event").parse(_event_spec)
            result.ft[event.id] = event
        end
    end
    local ft_spec = spec.ft
    if ft_spec then
        result.ft = {}
    end
    if type(ft_spec) == "string" then
        local ft = require("lz.n.handler.ft").parse(ft_spec)
        result[ft.id] = ft
    elseif type(ft_spec) == "table" then
        for _, _ft_spec in pairs(ft_spec) do
            local ft = require("lz.n.handler.ft").parse(_ft_spec)
            result.ft[ft.id] = ft
        end
    end
    local keys_spec = spec.keys
    if keys_spec then
        result.keys = {}
    end
    if type(keys_spec) == "string" then
        local keys = require("lz.n.handler.keys").parse(keys_spec)
        result.keys[keys.id] = keys
    elseif type(keys_spec) == "table" then
        ---@cast keys_spec string[] | LzKeysSpec[]
        for _, _keys_spec in pairs(keys_spec) do
            local keys = require("lz.n.handler.keys").parse(_keys_spec)
            result.keys[keys.id] = keys
        end
    end
    local cmd_spec = spec.cmd
    if cmd_spec then
        result.cmd = {}
    end
    if type(cmd_spec) == "string" then
        result.cmd[cmd_spec] = cmd_spec
    elseif type(cmd_spec) == "table" then
        for _, _cmd_spec in pairs(cmd_spec) do
            result.cmd[_cmd_spec] = _cmd_spec
        end
    end
    return result
end

---@private
---@param spec LzSpec
---@param result table<string, LzPlugin>
function M._normalize(spec, result)
    if #spec > 1 or vim.islist(spec) then
        for _, sp in ipairs(spec) do
            M._normalize(sp, result)
        end
    elseif spec.name then
        ---@cast spec LzPluginSpec
        result[spec.name] = parse(spec)
    elseif spec.import then
        ---@cast spec LzSpecImport
        import_spec(spec, result)
    end
end

---@param result table<string, LzPlugin>
local function remove_disabled_plugins(result)
    for _, plugin in ipairs(result) do
        local disabled = plugin.enabled == false or (type(plugin.enabled) == "function" and not plugin.enabled())
        if disabled then
            result[plugin.name] = nil
        end
    end
end

---@param spec LzSpec
---@return table<string, LzPlugin>
function M.parse(spec)
    local result = {}
    M._normalize(spec, result)
    remove_disabled_plugins(result)
    return result
end

return M
