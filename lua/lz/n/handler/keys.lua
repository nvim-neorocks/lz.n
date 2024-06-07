local loader = require("lz.n.loader")

---@class lz.n.KeysHandler: lz.n.Handler

---@type lz.n.KeysHandler
local M = {
    pending = {},
    type = "keys",
    ---@param value string|lz.n.KeysSpec
    ---@param mode? string
    ---@return lz.n.Keys
    parse = function(value, mode)
        value = type(value) == "string" and { value } or value --[[@as lz.n.KeysSpec]]
        local ret = vim.deepcopy(value) --[[@as lz.n.Keys]]
        ret.lhs = ret[1] or ""
        ret.rhs = ret[2]
        ret[1] = nil
        ret[2] = nil
        ret.mode = mode or "n"
        ret.id = vim.api.nvim_replace_termcodes(ret.lhs, true, true, true)
        if ret.ft then
            local ft = type(ret.ft) == "string" and { ret.ft } or ret.ft --[[@as string[] ]]
            ret.id = ret.id .. " (" .. table.concat(ft, ", ") .. ")"
        end
        if ret.mode ~= "n" then
            ret.id = ret.id .. " (" .. ret.mode .. ")"
        end
        return ret
    end,
}

local skip = { mode = true, id = true, ft = true, rhs = true, lhs = true }

---@param keys lz.n.Keys
---@return lz.n.KeysBase
local function get_opts(keys)
    ---@type lz.n.KeysBase
    local opts = {}
    for k, v in pairs(keys) do
        if type(k) ~= "number" and not skip[k] then
            opts[k] = v
        end
    end
    return opts
end

-- Create a mapping if it is managed by lz.n
---@param keys lz.n.Keys
---@param buf integer?
local function set(keys, buf)
    if keys.rhs then
        local opts = get_opts(keys)
        ---@diagnostic disable-next-line: inject-field
        opts.buffer = buf
        vim.keymap.set(keys.mode, keys.lhs, keys.rhs, opts)
    end
end

-- Delete a mapping and create the real global
-- mapping when needed
---@param keys lz.n.Keys
local function del(keys)
    pcall(vim.keymap.del, keys.mode, keys.lhs, {
        -- NOTE: for buffer-local mappings, we only delete the mapping for the current buffer
        -- So the mapping could still exist in other buffers
        buffer = keys.ft and true or nil,
    })
    -- make sure to create global mappings when needed
    -- buffer-local mappings are managed by lazy
    if not keys.ft then
        set(keys)
    end
end

---@param keys lz.n.Keys
local function add_keys(keys)
    local lhs = keys.lhs
    local opts = get_opts(keys)

    ---@param buf? number
    local function add(buf)
        vim.keymap.set(keys.mode, lhs, function()
            local plugins = M.pending[keys.id]
            -- always delete the mapping immediately to prevent recursive mappings
            del(keys)
            M.pending[keys.id] = nil
            if plugins then
                loader.load(plugins)
            end
            -- Create the real buffer-local mapping
            if keys.ft then
                set(keys, buf)
            end
            if keys.mode:sub(-1) == "a" then
                lhs = lhs .. "<C-]>"
            end
            local feed = vim.api.nvim_replace_termcodes("<Ignore>" .. lhs, true, true, true)
            -- insert instead of append the lhs
            vim.api.nvim_feedkeys(feed, "i", false)
        end, {
            desc = opts.desc,
            nowait = opts.nowait,
            -- we do not return anything, but this is still needed to make operator pending mappings work
            expr = true,
            buffer = buf,
        })
    end
    -- buffer-local mappings
    if keys.ft then
        vim.api.nvim_create_autocmd("FileType", {
            pattern = keys.ft,
            callback = function(event)
                if M.pending[keys.id] then
                    add(event.buf)
                else
                    -- Only create the mapping if its managed by lz.n
                    -- otherwise the plugin is supposed to manage it
                    set(keys, event.buf)
                end
            end,
        })
    else
        add()
    end
end

---@param plugin lz.n.Plugin
function M.add(plugin)
    for _, key in pairs(plugin.keys or {}) do
        M.pending[key.id] = M.pending[key.id] or {}
        M.pending[key.id][plugin.name] = plugin.name
        add_keys(key)
    end
end

---@param plugin lz.n.Plugin
function M.del(plugin)
    for _, plugins in pairs(M.pending) do
        plugins[plugin.name] = nil
    end
end

return M
