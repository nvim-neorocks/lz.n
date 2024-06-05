---@meta
error("Cannot import a meta module")

---@class VimGTable vim.g config table
---@field name? string Name of the vim.g config table, e.g. "rustaceanvim" for "vim.g.rustaceanvim". Defaults to the plugin name.
---@field type 'vim.g'

---@class ConfigFunction Lua function
---@field module? string Module name containing the function. Defaults to the plugin name.
---@field name? string Name of the config function. Defaults to 'setup', the most common in the Neovim plugin community.
---@field type 'func'

---@alias LzPluginOptsSpec VimGTable | ConfigFunction How a plugin accepts its options

---@class LzPluginBase
---@field name string Display name and name used for plugin config files, e.g. "neorg"
---@field optsSpec? LzPluginOptsSpec
---@field enabled? boolean|(fun():boolean)
---@field enable? boolean|(fun():boolean) Whether to enable this plugin. Useful to disable plugins under certain conditions.
---@field lazy? boolean
---@field priority? number Only useful for lazy=false plugins to force loading certain plugins first. Default priority is 50

---@alias LzEvent {id:string, event:string[]|string, pattern?:string[]|string}
---@alias LzEventSpec string|{event?:string|string[], pattern?:string|string[]}|string[]

---@alias PluginOpts table|fun(self:LzPlugin, opts:table):table?

---@class LzPluginHooks
---@field beforeAll? fun(self:LzPlugin) Will be run before loading any plugins
---@field deactivate? fun(self:LzPlugin) Unload/Stop a plugin
---@field after? fun(self:LzPlugin, opts:table)|true Will be executed when loading the plugin
---@field opts? PluginOpts

---@class LzPluginHandlers
---@field event? LzEvent[]
---@field ft? LzEvent[]
---@field keys? LzKeys[]
---@field cmd? string[]

---@class LzPluginSpecHandlers
---@field event? string|LzEventSpec[]
---@field cmd? string[]|string
---@field ft? string[]|string
---@field keys? string|string[]|LzKeysSpec[]
---@field module? false

---@class LzKeysBase: vim.keymap.set.Opts
---@field desc? string
---@field noremap? boolean
---@field remap? boolean
---@field expr? boolean
---@field nowait? boolean
---@field ft? string|string[]

---@class LzKeysSpec: LzKeysBase
---@field [1] string lhs
---@field [2]? string|fun()|false rhs
---@field mode? string|string[]

---@class LzKeys: LzKeysBase
---@field lhs string lhs
---@field rhs? string|fun() rhs
---@field mode? string
---@field id string
---@field name string

---@package
---@class LzPlugin: LzPluginBase,LzPluginHandlers,LzPluginHooks

---@class LzPluginSpec: LzPluginBase,LzPluginSpecHandlers,LzPluginHooks

---@alias LzSpec LzPluginSpec|LzSpecImport|LzSpec[]

---@class LzSpecImport
---@field import string spec module to import
---@field enabled? boolean|(fun():boolean)
---@field cond? boolean|(fun():boolean)
