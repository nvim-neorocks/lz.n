---@meta
error("Cannot import a meta module")

---@class VimGTable vim.g config table
---@field name? string Name of the vim.g config table, e.g. "rustaceanvim" for "vim.g.rustaceanvim". Defaults to the plugin name.
---@field type 'vim.g'

---@class ConfigFunction Lua function
---@field module? string Module name containing the function. Defaults to the plugin name.
---@field name? string Name of the config function. Defaults to 'setup', the most common in the Neovim plugin community.
---@field type 'func'

---@alias lz.n.PluginOptsSpec VimGTable | ConfigFunction How a plugin accepts its options

---@class lz.n.PluginBase
---@field name string Display name and name used for plugin config files, e.g. "neorg"
---@field optsSpec? lz.n.PluginOptsSpec
---@field enabled? boolean|(fun():boolean)
---@field enable? boolean|(fun():boolean) Whether to enable this plugin. Useful to disable plugins under certain conditions.
---@field lazy? boolean
---@field priority? number Only useful for lazy=false plugins to force loading certain plugins first. Default priority is 50

---@alias lz.n.Event {id:string, event:string[]|string, pattern?:string[]|string}
---@alias lz.n.EventSpec string|{event?:string|string[], pattern?:string|string[]}|string[]

---@alias PluginOpts table|fun(self:lz.n.Plugin, opts:table):table?

---@class lz.n.PluginHooks
---@field beforeAll? fun(self:lz.n.Plugin) Will be run before loading any plugins
---@field deactivate? fun(self:lz.n.Plugin) Unload/Stop a plugin
---@field after? fun(self:lz.n.Plugin, opts:table)|true Will be executed when loading the plugin
---@field opts? PluginOpts

---@class lz.n.PluginHandlers
---@field event? lz.n.Event[]
---@field keys? lz.n.Keys[]
---@field cmd? string[]

---@class lz.n.PluginSpecHandlers
---@field event? string|lz.n.EventSpec[]
---@field cmd? string[]|string
---@field ft? string[]|string
---@field keys? string|string[]|lz.n.KeysSpec[]
---@field module? false

---@class lz.n.KeysBase: vim.keymap.set.Opts
---@field desc? string
---@field noremap? boolean
---@field remap? boolean
---@field expr? boolean
---@field nowait? boolean
---@field ft? string|string[]

---@class lz.n.KeysSpec: lz.n.KeysBase
---@field [1] string lhs
---@field [2]? string|fun()|false rhs
---@field mode? string|string[]

---@class lz.n.Keys: lz.n.KeysBase
---@field lhs string lhs
---@field rhs? string|fun() rhs
---@field mode? string
---@field id string
---@field name string

---@package
---@class lz.n.Plugin: lz.n.PluginBase,lz.n.PluginHandlers,lz.n.PluginHooks

---@class lz.n.PluginSpec: lz.n.PluginBase,lz.n.PluginSpecHandlers,lz.n.PluginHooks

---@alias lz.n.Spec lz.n.PluginSpec|lz.n.SpecImport|lz.n.Spec[]

---@class lz.n.SpecImport
---@field import string spec module to import
---@field enabled? boolean|(fun():boolean)
---@field cond? boolean|(fun():boolean)
