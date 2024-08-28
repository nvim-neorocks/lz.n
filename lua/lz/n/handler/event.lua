local loader = require("lz.n.loader")

---@class lz.n.EventOpts
---@field event string
---@field group? string
---@field exclude? string[] augroups to exclude
---@field data? unknown
---@field buffer? number

---@class lz.n.EventHandler: lz.n.Handler
---@field events table<string,true>
---@field group number
---@field parse fun(spec: lz.n.EventSpec): lz.n.Event

local lz_n_events = {
    DeferredUIEnter = { id = "DeferredUIEnter", event = "User", pattern = "DeferredUIEnter" },
}

lz_n_events["User DeferredUIEnter"] = lz_n_events.DeferredUIEnter

---@type lz.n.handler.State
local state = require("lz.n.handler.state").new()

---@type lz.n.EventHandler
local M = {
    events = {},
    group = vim.api.nvim_create_augroup("lz_n_handler_event", { clear = true }),
    spec_field = "event",
    ---@param spec lz.n.EventSpec
    parse = function(spec)
        local ret = lz_n_events[spec]
        if ret then
            return ret
        end
        if type(spec) == "string" then
            local event, pattern = spec:match("^(%w+)%s+(.*)$")
            event = event or spec
            return { id = spec, event = event, pattern = pattern }
        elseif vim.islist(spec) then
            ret = { id = table.concat(spec, "|"), event = spec }
        else
            ret = spec --[[@as lz.n.Event]]
            if not ret.id then
                ---@diagnostic disable-next-line: assign-type-mismatch, param-type-mismatch
                ret.id = type(ret.event) == "string" and ret.event or table.concat(ret.event, "|")
                if ret.pattern then
                    ---@diagnostic disable-next-line: assign-type-mismatch, param-type-mismatch
                    ret.id = ret.id
                        .. " "
                        .. (
                            type(ret.pattern) == "string" and ret.pattern
                            or table.concat(ret.pattern --[[@as table]], ", ")
                        )
                end
            end
        end
        return ret
    end,
}

---@param name string
---@return lz.n.Plugin?
function M.lookup(name)
    return state.lookup_plugin(name)
end

-- Get all augroups for an event
---@param event string
---@return string[]
local function get_augroups(event)
    return vim.iter(vim.api.nvim_get_autocmds({ event = event }))
        :filter(function(autocmd)
            return autocmd.group_name ~= nil
        end)
        :map(function(autocmd)
            return autocmd.group_name
        end)
        :totable()
end

local event_triggers = {
    FileType = "BufReadPost",
    BufReadPost = "BufReadPre",
}
-- Get the current state of the event and all the events that will be fired
---@param event string
---@param buf integer
---@param data unknown
---@return lz.n.EventOpts[]
local function get_state(event, buf, data)
    ---@type lz.n.EventOpts[]
    local st = {}
    while event do
        ---@type lz.n.EventOpts
        local event_opts = {
            event = event,
            exclude = event ~= "FileType" and get_augroups(event) or nil,
            buffer = buf,
            data = data,
        }
        table.insert(st, 1, event_opts)
        data = nil -- only pass the data to the first event
        event = event_triggers[event]
    end
    return st
end

-- Trigger an event
---@param opts lz.n.EventOpts
local function _trigger(opts)
    xpcall(
        function()
            vim.api.nvim_exec_autocmds(opts.event, {
                buffer = opts.buffer,
                group = opts.group,
                modeline = false,
                data = opts.data,
            })
        end,
        vim.schedule_wrap(function(err)
            vim.notify(err, vim.log.levels.ERROR)
        end)
    )
end

-- Trigger an event. When a group is given, only the events in that group will be triggered.
-- When exclude is set, the events in those groups will be skipped.
---@param opts lz.n.EventOpts
local function trigger(opts)
    if opts.group or opts.exclude == nil then
        return _trigger(opts)
    end
    ---@type table<string,true>
    local done = {}
    vim.iter(vim.api.nvim_get_autocmds({ event = opts.event })):each(function(autocmd)
        local id = autocmd.event .. ":" .. (autocmd.group or "") ---@type string
        local skip = done[id] or (opts.exclude and vim.tbl_contains(opts.exclude, autocmd.group_name))
        done[id] = true
        if autocmd.group and not skip then
            ---@diagnostic disable-next-line: assign-type-mismatch
            opts.group = autocmd.group_name
            _trigger(opts)
        end
    end)
end

---@param event lz.n.Event
local function add_event(event)
    local done = false
    vim.api.nvim_create_autocmd(event.event, {
        group = M.group,
        once = true,
        pattern = event.pattern,
        callback = function(ev)
            if done or not state.has_pending_plugins(event.id) then
                return
            end
            -- HACK: work-around for https://github.com/neovim/neovim/issues/25526
            done = true
            local st = get_state(ev.event, ev.buf, ev.data)
            state.each_pending(event.id, loader.load)
            ---@param s lz.n.EventOpts
            vim.iter(st):each(function(s)
                trigger(s)
            end)
        end,
    })
end

---@param plugin lz.n.Plugin
function M.add(plugin)
    ---@param event lz.n.Event
    vim.iter(plugin.event or {}):each(function(event)
        state.insert(event.id, plugin)
        add_event(event)
    end)
end

---@param name string
function M.del(name)
    state.del(name)
end

return M
