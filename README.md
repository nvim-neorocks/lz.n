# :sleeping_bed: lz.n

A dead simple lazy-loading Lua library for Neovim plugins.

It is intended to be used

- by users or plugin managers that don't provide a convenient API for lazy-loading.
- by plugin managers, to provide a convenient API for lazy-loading.

![Neovim](https://img.shields.io/badge/NeoVim-%2357A143.svg?&style=for-the-badge&logo=neovim&logoColor=white)
![Lua](https://img.shields.io/badge/lua-%232C2D72.svg?style=for-the-badge&logo=lua&logoColor=white)

> [!NOTE]
>
> **Should I lazy-load plugins?**
>
> It should be a plugin author's responsibility to ensure their plugin doesn't
> unnecessarily impact startup time, not yours!
>
> See [our "DO's and DONT's" guide for plugin developers](https://github.com/nvim-neorocks/nvim-best-practices?tab=readme-ov-file#sleeping_bed-lazy-loading).
>
> Regardless, the current status quo is horrible, and some authors may
> not have the will or capacity to improve their plugins' startup impact.
>
> If you find a plugin that takes too long to load,
> or worse, forces you to load it manually at startup with a
> call to a heavy `setup` function,
> consider opening an issue on the plugin's issue tracker.

## :star2: Features

- API for lazy-loading plugins on:
  - Events (`:h autocmd-events`)
  - `FileType` events
  - Key mappings
  - User commands
- Works with:
  - Neovim's built-in `:h packpath` (`:h packadd`)
  - Any plugin manager that supports manually lazy loading
    plugins by name
- Configurable in multiple files

## :moon: Introduction

`lz.n` provides abstractions for lazy-loading Neovim plugins,
with an API that is loosely based on [`lazy.nvim`](https://github.com/folke/lazy.nvim),
but reduced down to the very basics required for lazy-loading only.

### :milky_way: Philosophy

`lz.n` is designed based on the UNIX philosophy: Do one thing well.

### :zzz: Comparison with `lazy.nvim`

- `lz.n` is **not a plugin manager**, but focuses **on lazy-loading only**.
  It is intended to be used with (or by) a plugin manager.
- The feature set is minimal, to [reduce code complexity](https://grugbrain.dev/)
  and simplify the API.
  For example, the following `lazy.nvim` features are **out of scope**:
  - Merging multiple plugin specs for a single plugin
    (primarily intended for use by Neovim distributions).
  - Automatic lazy-loading of Lua modules on `require`.
  - Automatic lazy-loading of colorschemes.
  - Heuristics for determining a `main` module and automatically calling
    a `setup()` function.
  - Abstractions for plugin configuration with an `opts` table.
    This plugin provides simple hooks that you can use to specify
    when to load configurations.
  - Features related to plugin management.
  - Profiling tools.
  - UI.
- Some configuration options are different.

## :pencil: Requirements

- `Neovim >= 0.10.0`

## :wrench: Configuration

You can override the function used to load plugins.
`lz.n` has the following default:

```lua
vim.g.lz_n = {
    ---@type fun(string: name)
    load = vim.cmd.packadd,
}
```

## :books: Usage

```lua
require("lz.n").load(plugins)
```

- **plugins**: this should be a `table` or a `string`
  - `table`: a list with your [Plugin Spec](#plugin-spec)
  - `string`: a Lua module name that contains your [Plugin Spec](#plugin-spec).
    See [Structuring Your Plugins](#structuring-your-plugins)

### Plugin spec

<!-- markdownlint-disable MD013 -->
| Property         | Type | Description | `lazy.nvim` eqivalent |
|------------------|------|-------------|-----------------------|
| **[1]** | `string` | The plugin's name (not the module name). | `name`[^1] |
| **enabled** | `boolean?` or `fun():boolean` | When `false`, or if the `function` returns false, then this plugin will not be included in the spec. | `enabled` |
| **beforeAll** | `fun(lz.n.Plugin)?` | Always executed before any plugins are loaded. | `init` |
| **before** | `fun(lz.n.Plugin)?` | Executed before a plugin is loaded. | - |
| **after** | `fun(lz.n.Plugin)?` | Executed after a plugin is loaded. | `config` |
| **event** | `string?` or `{event?:string\|string[], pattern?:string\|string[]}\` or `string[]` | Lazy-load on event. Events can be specified as `BufEnter` or with a pattern like `BufEnter *.lua`. | `event` |
| **cmd** | `string?` or `string[]` | Lazy-load on command. | `cmd` |
| **ft** | `string?` or `string[]` | Lazy-load on filetype. | `ft` |
| **keys** | `string?` or `string[]` or `lz.n.KeysSpec[]` | Lazy-load on key mapping. | `keys` |
| **priority** | `number?` | Only useful for **start** plugins (not lazy-loaded) to force loading certain plugins first. Default priority is `50`. It's recommended to set this to a high number for colorschemes. | `priority` |
<!-- markdownlint-enable MD013 -->

[^1]: In contrast to `lazy.nvim`'s `name` field, `lz.n`'s `name` *is not optional*.
      This is because `lz.n` does is not a plugin manager and needs to be told which
      plugins to load.

#### Example

```lua
require("lz.n").load {
    {
        "neo-tree.nvim",
        keys = {
            -- Create a key mapping and lazy-load when it is used
            { "<leader>ft", "<CMD>Neotree toggle<CR>", desc = "NeoTree toggle" },
        },
        after = function()
            require("neo-tree").setup()
        end,
    },
    {
        "crates.nvim",
        -- lazy-load when opening a toml file
        ft = "toml",
    },
    {
        "vim-startuptime",
        cmd = "StartupTime",
        before = function()
            -- Configuration for plugins that don't force you to call a `setup` function
            -- for initialization should typically go in a `before`
            --- or `beforeAll` function.
            vim.g.startuptime_tries = 10
        end,
    },
    {
        "nvim-cmp",
        -- load cmp on InsertEnter
        event = "InsertEnter",
    },
    {
        "dial.nvim",
        -- lazy-load on keys. -- Mode is `n` by default.
        keys = { "<C-a>", { "<C-x>", mode = "n" } },
    },
}
```

### Structuring Your Plugins

As is the case with `lazy.nvim`, you can also split your plugin specs
into multiple files.
Instead of passing a spec table to `load()`, you can use a Lua module.
The function will merge specs from the **module** and any top-level **sub-modules**
together in the final spec, so it is not needed to add `require` calls
in your main plugin file to the other files.

Example:

- `~/.config/nvim/init.lua`

```lua
require("lz.n").load("plugins")
```

- `~/.config/nvim/lua/plugins.lua` or `~/.config/nvim/lua/plugins/init.lua`
  **(this file is optional)**

```lua
return {
  { "sweetie.nvim" },
  { "telescope.nvim", cmd = "Telescope" },
}
```

- `lz.n` will automatically merge any Lua file in `~/.config/nvim/lua/plugins/*.lua`
  with the main plugin spec.

## :green_heart: Contributing

All contributions are welcome!
See [CONTRIBUTING.md](./CONTRIBUTING.md).

## :book: License

This library is [licensed](./LICENSE) according to GPL version 2
or (at your option) any later version.
