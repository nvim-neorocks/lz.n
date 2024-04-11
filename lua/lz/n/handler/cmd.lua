local loader = require('lz.n.loader')

---@class LzCmdHandler: LzHandler

---@type LzCmdHandler
local M = {
  active = {},
  managed = {},
  type = 'cmd',
}

---@param cmd string
local function load(cmd)
  vim.api.nvim_del_user_command(cmd)
  loader.load(M.active[cmd])
end

---@param cmd string
local function add(cmd)
  vim.api.nvim_create_user_command(cmd, function(event)
    ---@cast event vim.api.keyset.user_command
    local command = {
      cmd = cmd,
      bang = event.bang or nil,
      ---@diagnostic disable-next-line: undefined-field
      mods = event.smods,
      ---@diagnostic disable-next-line: undefined-field
      args = event.fargs,
      count = event.count >= 0 and event.range == 0 and event.count or nil,
    }

    if event.range == 1 then
      ---@diagnostic disable-next-line: undefined-field
      command.range = { event.line1 }
    elseif event.range == 2 then
      ---@diagnostic disable-next-line: undefined-field
      command.range = { event.line1, event.line2 }
    end

    ---@type string
    local plugins = '`' .. table.concat(vim.tbl_values(M.active[cmd]), ', ') .. '`'

    load(cmd)

    local info = vim.api.nvim_get_commands({})[cmd] or vim.api.nvim_buf_get_commands(0, {})[cmd]
    if not info then
      vim.schedule(function()
        vim.notify('Command `' .. cmd .. '` not found after loading ' .. plugins, vim.log.levels.ERROR)
      end)
      return
    end

    command.nargs = info.nargs
    ---@diagnostic disable-next-line: undefined-field
    if event.args and event.args ~= '' and info.nargs and info.nargs:find('[1?]') then
      ---@diagnostic disable-next-line: undefined-field
      command.args = { event.args }
    end
    vim.cmd(command)
  end, {
    bang = true,
    range = true,
    nargs = '*',
    complete = function(_, line)
      load(cmd)
      return vim.fn.getcompletion(line, 'cmdline')
    end,
  })
end

---@param cmd string
function M.del(cmd)
  pcall(vim.api.nvim_del_user_command, cmd)
end

---@param plugin LzPlugin
function M.add(plugin)
  if not plugin.cmd then
    return
  end
  for _, cmd in pairs(plugin.cmd) do
    M.active[cmd] = M.active[cmd] or {}
    M.active[cmd][plugin.name] = plugin.name
    add(cmd)
  end
end

return M
