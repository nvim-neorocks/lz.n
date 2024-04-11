local loader = require('lz.n.loader')

---@class LzEventOpts
---@field event string
---@field group? string
---@field exclude? string[] augroups to exclude
---@field data? unknown
---@field buffer? number

---@class LzEventHandler: LzHandler
---@field events table<string,true>
---@field group number

---@type LzEventHandler
local M = {
  active = {},
  managed = {},
  type = 'event',
}

---@param spec LzEventSpec
---@return LzEvent
function M.parse(spec)
  local ret
  if type(spec) == 'string' then
    local event, pattern = spec:match('^(%w+)%s+(.*)$')
    event = event or spec
    return { id = spec, event = event, pattern = pattern }
  elseif vim.tbl_islist(spec) then
    ret = { id = table.concat(spec, '|'), event = spec }
  else
    ret = spec --[[@as LzEvent]]
    if not ret.id then
      ---@diagnostic disable-next-line: assign-type-mismatch, param-type-mismatch
      ret.id = type(ret.event) == 'string' and ret.event or table.concat(ret.event, '|')
      if ret.pattern then
        ---@diagnostic disable-next-line: assign-type-mismatch, param-type-mismatch
        ret.id = ret.id .. ' ' .. (type(ret.pattern) == 'string' and ret.pattern or table.concat(ret.pattern, ', '))
      end
    end
  end
  return ret
end

-- Get all augroups for an event
---@param event string
local function get_augroups(event)
  ---@type string[]
  local groups = {}
  for _, autocmd in ipairs(vim.api.nvim_get_autocmds { event = event }) do
    if autocmd.group_name then
      table.insert(groups, autocmd.group_name)
    end
  end
  return groups
end

local event_triggers = {
  FileType = 'BufReadPost',
  BufReadPost = 'BufReadPre',
}
-- Get the current state of the event and all the events that will be fired
---@param event string
---@param buf integer
---@param data unknown
---@return LzEventOpts[]
local function get_state(event, buf, data)
  ---@type LzEventOpts[]
  local state = {}
  while event do
    ---@type LzEventOpts
    local event_opts = {
      event = event,
      exclude = event ~= 'FileType' and get_augroups(event) or nil,
      buffer = buf,
      data = data,
    }
    table.insert(state, 1, event_opts)
    data = nil -- only pass the data to the first event
    event = event_triggers[event]
  end
  return state
end

-- Trigger an event
---@param opts LzEventOpts
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
---@param opts LzEventOpts
local function trigger(opts)
  if opts.group or opts.exclude == nil then
    return _trigger(opts)
  end
  ---@type table<string,true>
  local done = {}
  for _, autocmd in ipairs(vim.api.nvim_get_autocmds { event = opts.event }) do
    local id = autocmd.event .. ':' .. (autocmd.group or '') ---@type string
    local skip = done[id] or (opts.exclude and vim.tbl_contains(opts.exclude, autocmd.group_name))
    done[id] = true
    if autocmd.group and not skip then
      opts.group = autocmd.group_name
      _trigger(opts)
    end
  end
end

---@param event LzEvent
function M.add(event)
  local done = false
  vim.api.nvim_create_autocmd(event.event, {
    group = M.group,
    once = true,
    pattern = event.pattern,
    callback = function(ev)
      if done or not M.active[event.id] then
        return
      end
      -- HACK: work-around for https://github.com/neovim/neovim/issues/25526
      done = true
      local state = get_state(ev.event, ev.buf, ev.data)
      -- load the plugins
      loader.load(M.active[event.id])
      -- check if any plugin created an event handler for this event and fire the group
      for _, s in ipairs(state) do
        trigger(s)
      end
    end,
  })
end

return M
