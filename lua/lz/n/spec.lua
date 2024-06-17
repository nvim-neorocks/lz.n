local M = {}

---@param modname string
---@param result table<string, lz.n.Plugin>
local function import_modname(modname, result)
    local ok, mod = pcall(require, modname)
    if not ok then
        vim.schedule(function()
            local err = type(mod) == "string" and ": " .. mod or ""
            vim.notify("Failed to load module '" .. modname .. err, vim.log.levels.ERROR)
        end)
        return
    end
    if type(mod) ~= "table" then
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

---@param spec lz.n.SpecImport
---@param result table<string, lz.n.Plugin>
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
    if spec.enabled == false or (type(spec.enabled) == "function" and not spec.enabled()) then
        return
    end
    local modname = spec.import
    local import_root = vim.api.nvim_get_runtime_file(vim.fs.joinpath("lua", modname .. ".lua"), true)
    if #import_root == 1 then
        import_modname(modname, result)
    end
    local import_dir = vim.api.nvim_get_runtime_file(vim.fs.joinpath("lua", modname), true)
    if #import_dir == 1 then
        local dir = import_dir[1]
        local handle = vim.uv.fs_scandir(dir)
        while handle do
            local name, ty = vim.uv.fs_scandir_next(handle)
            local path = vim.fs.joinpath(dir, name)
            ty = ty or vim.uv.fs_stat(path).type
            if not name then
                break
            elseif ty == "file" then
                local submodname = vim.fn.fnamemodify(name, ":r")
                import_modname(modname .. "." .. submodname, result)
            end
        end
    end
end

---@param spec lz.n.PluginSpec
---@return lz.n.Plugin
local function parse(spec)
    ---@type lz.n.Plugin
    ---@diagnostic disable-next-line: assign-type-mismatch
    local result = vim.deepcopy(spec)
    result.name = spec[1]
    result[1] = nil
    local event_spec = spec.event
    if event_spec then
        result.event = {}
    end
    if type(event_spec) == "string" then
        local event = require("lz.n.handler.event").parse(event_spec)
        table.insert(result.event, event)
    elseif type(event_spec) == "table" then
        ---@cast event_spec lz.n.EventSpec[]
        for _, _event_spec in pairs(event_spec) do
            local event = require("lz.n.handler.event").parse(_event_spec)
            table.insert(result.event, event)
        end
    end
    local ft_spec = spec.ft
    if ft_spec then
        result.event = result.event or {}
        ---@diagnostic disable-next-line: inject-field
        result.ft = nil
    end
    if type(ft_spec) == "string" then
        local ft = require("lz.n.handler.ft").parse(ft_spec)
        table.insert(result.event, ft)
    elseif type(ft_spec) == "table" then
        for _, _ft_spec in pairs(ft_spec) do
            local ft = require("lz.n.handler.ft").parse(_ft_spec)
            table.insert(result.event, ft)
        end
    end
    local keys_spec = spec.keys
    if keys_spec then
        result.keys = {}
    end
    if type(keys_spec) == "string" then
        local keys = require("lz.n.handler.keys").parse(keys_spec)
        table.insert(result.keys, keys)
    elseif type(keys_spec) == "table" then
        ---@cast keys_spec string[] | lz.n.KeysSpec[]
        for _, _keys_spec in pairs(keys_spec) do
            local keys = require("lz.n.handler.keys").parse(_keys_spec)
            table.insert(result.keys, keys)
        end
    end
    local cmd_spec = spec.cmd
    if cmd_spec then
        result.cmd = {}
    end
    if type(cmd_spec) == "string" then
        table.insert(result.cmd, cmd_spec)
    elseif type(cmd_spec) == "table" then
        for _, _cmd_spec in pairs(cmd_spec) do
            table.insert(result.cmd, _cmd_spec)
        end
    end
    local colorscheme_spec = spec.colorscheme
    if colorscheme_spec then
        result.colorscheme = {}
    end
    if type(colorscheme_spec) == "string" then
        table.insert(result.colorscheme, colorscheme_spec)
    elseif type(colorscheme_spec) == "table" then
        for _, _colorscheme_spec in pairs(colorscheme_spec) do
            table.insert(result.colorscheme, _colorscheme_spec)
        end
    end
    result.lazy = result.lazy
        or result.event ~= nil
        or result.keys ~= nil
        or result.cmd ~= nil
        or result.colorscheme ~= nil
    return result
end

---@param spec lz.n.Spec
---@return boolean
function M.is_spec_list(spec)
    return #spec > 1 or vim.islist(spec) and #spec > 1
end

---@param spec lz.n.Spec
---@return boolean
function M.is_single_plugin_spec(spec)
    return type(spec[1]) == "string"
end

---@private
---@param spec lz.n.Spec
---@param result table<string, lz.n.Plugin>
function M._normalize(spec, result)
    if M.is_spec_list(spec) then
        ---@cast spec lz.n.Spec[]
        for _, sp in ipairs(spec) do
            M._normalize(sp, result)
        end
    elseif M.is_single_plugin_spec(spec) then
        ---@cast spec lz.n.PluginSpec
        result[spec[1]] = parse(spec)
    elseif spec.import then
        ---@cast spec lz.n.SpecImport
        import_spec(spec, result)
    end
end

---@param result table<string, lz.n.Plugin>
local function remove_disabled_plugins(result)
    for _, plugin in ipairs(result) do
        local disabled = plugin.enabled == false or (type(plugin.enabled) == "function" and not plugin.enabled())
        if disabled then
            result[plugin.name] = nil
        end
    end
end

---@param spec lz.n.Spec
---@return table<string, lz.n.Plugin>
function M.parse(spec)
    local result = {}
    M._normalize(spec, result)
    remove_disabled_plugins(result)
    return result
end

return M
