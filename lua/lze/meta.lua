---@meta
error("Cannot import a meta module")

--- @class lze.PluginBase
---
--- Whether to enable this plugin. Useful to disable plugins under certain conditions.
--- @field enabled? boolean|(fun():boolean)
---
--- Only useful for lazy=false plugins to force loading certain plugins first.
--- Default priority is 50
--- @field priority? number
---
--- Set this to override the `load` function for an individual plugin.
--- Defaults to `vim.g.lze.load()`, see |lze.Config|.
--- @field load? fun(name: string)

--- @alias lze.Event {id:string, event:string[]|string, pattern?:string[]|string}
--- @alias lze.EventSpec string|{event?:string|string[], pattern?:string|string[]}|string[]

--- @class lze.PluginHooks
--- @field beforeAll? fun(self:lze.Plugin) Will be run before loading any plugins in that require('lze').load() call
--- @field before? fun(self:lze.Plugin) Will be run before loading this plugin
--- @field after? fun(self:lze.Plugin) Will be executed after loading this plugin

--- @class lze.KeysBase: vim.keymap.set.Opts
--- @field desc? string
--- @field noremap? boolean
--- @field remap? boolean
--- @field expr? boolean
--- @field nowait? boolean
--- @field ft? string|string[]

--- @class lze.KeysSpec: lze.KeysBase
--- @field [1] string lhs
--- @field [2]? string|fun()|false rhs
--- @field mode? string|string[]

--- @class lze.Keys: lze.KeysBase
--- @field lhs string lhs
--- @field rhs? string|fun() rhs
--- @field mode? string
--- @field id string
--- @field name string

--- @class lze.SpecHandlers
---
--- Load a plugin on one or more |autocmd-events|.
--- @field event? string|lze.EventSpec[]
---
--- Load a plugin on one or more |user-commands|.
--- @field cmd? string[]|string
---
--- Load a plugin on one or more |FileType| events.
--- @field ft? string[]|string
---
--- Load a plugin on one or more |key-mapping|s.
--- @field keys? string|string[]|lze.KeysSpec[]
---
--- Load a plugin on one or more |colorscheme| events.
--- @field colorscheme? string[]|string
---
--- Load a plugin after load of one or more other plugins.
--- @field on_plugin? string[]|string
---
--- Load a plugin before load of one or more other plugins.
--- @field dep_of? string[]|string

--- @class lze.Plugin: lze.PluginBase,lze.PluginHooks,lze.SpecHandlers
--- The plugin name (not its main module), e.g. "sweetie.nvim"
--- @field name string
---
--- Whether to lazy-load this plugin. Defaults to `false`.
--- @field lazy? boolean

--- @class lze.PluginSpec: lze.PluginBase,lze.PluginHooks,lze.SpecHandlers
--- The plugin name (not its main module), e.g. "sweetie.nvim"
--- @field [1] string

--- @class lze.SpecImport
--- @field import string spec module to import
--- @field enabled? boolean|(fun():boolean)

--- @alias lze.Spec lze.PluginSpec | lze.SpecImport | lze.Spec[]

--- @class lze.Config
---
--- Callback to load a plugin.
--- Takes the plugin name (not the module name). Defaults to |packadd| if not set.
--- @field load? fun(name: string)

--- @class lze.Handler
--- @field spec_field string
--- @field add fun(plugin: lze.Plugin)
--- @field before? fun(plugin: lze.Plugin)
--- @field after? fun(plugin: lze.Plugin)

---@class lze.HandlerSpec
---@field handler lze.Handler
---@field enabled? boolean|(fun():boolean)

--- @type lze.Config
vim.g.lze = vim.g.lze
