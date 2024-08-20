# :sloth: lze

[![Neovim][neovim-shield]][neovim-url]
[![Lua][lua-shield]][lua-url]
<!-- [![LuaRocks][luarocks-shield]][luarocks-url] -->

`lze` is a simple lazy-loading Lua library for Neovim plugins.

It is intended to be used

- by users of plugin managers that don't provide a convenient API for lazy-loading.
- by plugin managers, to provide a convenient API for lazy-loading.

> [!NOTE]
>
> **Should I lazy-load plugins?**
>
> It should be a plugin author's responsibility to ensure their plugin doesn't
> unnecessarily impact startup time, not yours!
>
> See [nvim-neorocks' "DO's and DONT's" guide for plugin developers](https://github.com/nvim-neorocks/nvim-best-practices?tab=readme-ov-file#sleeping_bed-lazy-loading).
>
> Regardless, the current status quo is horrible, and some authors may
> not have the will or capacity to improve their plugins' startup impact.
>
> If you find a plugin that takes too long to load,
> or worse, forces you to load it manually at startup with a
> call to a heavy `setup` function,
> consider opening an issue on the plugin's issue tracker.

## :zzz: Why fork `lz.n`?

This is a fork of [nvim-neorocks/lz.n](https://github.com/nvim-neorocks/lz.n)
explicitly focused on ease of extensibility rather than simplicity.

It is still very simple, and simplicity is still a goal.

It also has more builtin allowances for dealing with plugin authors
who DON'T follow best practices, because that happens often.

`lze` takes a more flexible approach to the core spec processing,
and the managing of handlers, and the managing of how loading is called.

### Extensibility Improvements

- It allows you to influence the order handlers
  are called in, as opposed to being random.
- Handler implementations of even the built-in handlers
  are now decoupled from the core loading api,
  allowing full customization of the set of handlers available,
  and the order in which any handler is called.
- It provides a `before` and `after` hook for handler authors to use,
  rather than just `lz.n`'s `del` (equivalent to `before`).
  - Why is it not named `del` like in `lz.n`?
    - It doesn't matter to
    the core of `lze` if you delete the state in your handler.
    It might matter for *your* handler still, and is good practice,
    but thats only your problem, it will not break `lze`.
- It takes a simple, authoritative approach to state management,
  which reduces the responsibilities on handler authors
  in case they mess up their internal state, and also
  allows abuse of the api to be predictable if absolutely necessary.

### Minor QOL

- It allows multiple lists of plugin specs to be added.
- It provides 2 new handlers for loading before or after other plugins.
  (USUALLY NOT NECESSARY, as generally,
  dependencies are written to only load when called,
  and can be safely loaded at startup.)

## :star2: Features

- API for lazy-loading plugins on:
  - Events (`:h autocmd-events`)
  - `FileType` events
  - Key mappings
  - User commands
  - Colorscheme events
  - Other plugins
  - Anything you can write a [custom handler](#custom-handlers) for
- Works with:
  - Neovim's built-in `:h packpath` (`:h packadd`)
  - Any plugin manager that supports manually lazy-loading
    plugins by name
- Configurable in multiple files

## :moon: Introduction

`lze` provides abstractions for lazy-loading Neovim plugins,
with an API that is loosely based on [`lazy.nvim`](https://github.com/folke/lazy.nvim),
but reduced down to the very basics required for lazy-loading only.

If attempting lazy loading via autocommands, it can get very verbose
when you wish to load a plugin on multiple triggers.

This greatly simplifies that process, and is easy to extend with
your own custom fields via [custom handlers](#custom-handlers),
the same mechanism through which the builtin handlers are created.

### :milky_way: Philosophy

`lze` is designed based on the UNIX philosophy: Do one thing well.

### :zzz: Comparison with `lazy.nvim`

- `lze` is **not a plugin manager**, but focuses **on lazy-loading only**.
  It is intended to be used with (or by) a plugin manager.
- The feature set is minimal, to [reduce code complexity](https://grugbrain.dev/)
  and simplify the API.
  For example, the following `lazy.nvim` features are **out of scope**:
  - Merging multiple plugin specs for a single plugin
    (primarily intended for use by Neovim distributions).
  - `lazy.vim` completely disables and takes over Neovim's
    built-in loading mechanisms, including
    adding a plugin's API (`lua`, `autoload`, ...)
    to the runtimepath.
    `lze` doesn't.
    Its only concern is plugin initialization, which is
    the bulk of the startup overhead.
  - Automatic lazy-loading of Lua modules on `require`
    (without any user configuration).
  - Automatic lazy-loading of colorschemes.
    `lz.n` provides a `colorscheme` handler in the plugin spec.
  - Heuristics for determining a `main` module and automatically calling
    a `setup()` function.
  - Abstractions for plugin configuration with an `opts` table.
    `lz.n` provides simple hooks that you can use to specify
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
vim.g.lze = {
    ---@type fun(name: string)
    load = vim.cmd.packadd,
}
```

## :books: Usage

Anywhere in your config you may call this function
to register plugins for lazy loading!

```lua
require("lze").load(plugins)
```

- **plugins**: this should be a `table` or a `string`
  - `table`:
    - A list with your [Plugin Specs](#plugin-spec)
    - Or a single plugin spec.
  - `string`: a Lua module name that contains your [Plugin Spec](#plugin-spec).
    See [Structuring Your Plugins](#structuring-your-plugins)

> [!TIP]
>
> You can call `load()` as you would call `lazy.nvim`'s `setup()`.
> Or, you can also use it to register individual plugin specs for lazy
> loading. You may call it as many times as you wish, but
> it will throw an error if you try to add the same plugin multiple times.
> It does not merge them like `lazy.nvim` does.

### Plugin spec

#### Loading hooks

<!-- markdownlint-disable MD013 -->
| Property         | Type | Description | `lazy.nvim` equivalent |
|------------------|------|-------------|-----------------------|
| **[1]** | `string` | The plugin's name (not the module name). This is the directory name of the plugin in the packpath and is usually the same as the repo name of the repo it was cloned from. | `name`[^1] |
| **enabled** | `boolean?` or `fun():boolean` | When `false`, or if the `function` returns false, then this plugin will not be included in the spec. | `enabled` |
| **beforeAll** | `fun(lze.Plugin)?` | Always executed upon calling `require('lze').load(spec)` before any plugin specs from that call are triggered to be loaded. | `init` |
| **before** | `fun(lze.Plugin)?` | Executed before a plugin is loaded. | None |
| **after** | `fun(lze.Plugin)?` | Executed after a plugin is loaded. | `config` |
| **priority** | `number?` | Only useful for **start** plugins (not lazy-loaded) added within **the same `require('lze').load(spec)` call** to force loading certain plugins first. Default priority is `50`. | `priority` |
| **load** | `fun(string)?` | Can be used to override the `vim.g.lze.load(name)` function for an individual plugin. (default is `vim.cmd.packadd(name)`)[^2] | None. |
<!-- markdownlint-enable MD013 -->

#### Lazy-loading triggers provided by the default handlers

<!-- markdownlint-disable MD013 -->
| Property | Type | Description | `lazy.nvim` equivalent |
|----------|------|-------------|----------------------|
| **event** | `string?` or `{event?:string\|string[], pattern?:string\|string[]}\` or `string[]` | Lazy-load on event. Events can be specified as `BufEnter` or with a pattern like `BufEnter *.lua`. | `event` |
| **cmd** | `string?` or `string[]` | Lazy-load on command. | `cmd` |
| **ft** | `string?` or `string[]` | Lazy-load on filetype. | `ft` |
| **keys** | `string?` or `string[]` or `lze.KeysSpec[]` | Lazy-load on key mapping. | `keys` |
| **colorscheme** | `string?` or `string[]` | Lazy-load on colorscheme. Sets priority to 1000 [^3] | None. `lazy.nvim` lazy-loads colorschemes automatically[^4]. |
| **dep_of** | `string?` or `string[]` | Lazy-load before another plugin but after its `before` hook. Accepts a plugin name or a list of plugin names. |  None but is sorta the reverse of the dependencies key of the `lazy.nvim` plugin spec |
| **on_plugin** | `string?` or `string[]` | Lazy-load after another plugin but before its `after` hook. Accepts a plugin name or a list of plugin names. | None. |
<!-- markdownlint-enable MD013 -->

[^1]: In contrast to `lazy.nvim`'s `name` field, a `lze.PluginSpec`'s `name` *is not optional*.
      This is because `lze` is not a plugin manager and needs to be told which
      plugins to load.
[^2]: for example, lazy-loading cmp sources will
      require you to source its `after/plugin` file,
      as packadd does not do this automatically for you.
<!-- markdownlint-disable MD007 MD032 -->
[^3]: One of the main reasons this fork of `lz.n` exists, is that handlers are *completely*
    decoupled from the core code of `lze`. `lze` only knows about handlers by default
    because when you first require it, it calls `M.register_handlers(M.default_handlers)`.
    This means there is not code that would detect something like if the colorscheme
    handler has been enabled for a plugin in the core of `lze`.
    - That being said, `priority = 1000` still can be added, but requires a dirty hack.
    - `lze`'s state is actually authoritative, due to
    `trigger_load` not accepting a plugin spec like its `lz.n` equivalent does.
    - `add` is called *after* plugins are added to state, but *before*
    any loading occurs, even startup plugins.
    - I would not suggest using this fact yourself
    unless you really know what you are doing.
    - Handlers do not need to do this to add custom loading code,
      therefore there is VERY little reason to do this.
      - handlers have access to both a `before` and `after` hook
      - If they wish to affect the loading of a plugin, they can do so there
      - These hooks are one of the other reasons this fork exists.
        The other main reason is that handlers cannot mess things up by not
        properly deleting a plugin from their internal state.
<!-- markdownlint-enable MD007 MD032 -->
[^4]: The reason this library doesn't lazy-load colorschemes automatically is that
      it would have to know where the plugin is installed in order to determine
      which plugin to load.

### User events

- `DeferredUIEnter`: Triggered when `require('lze').load()` is done and after `UIEnter`.
  Can be used as an `event` to lazy-load plugins that are not immediately needed
  for the initial UI[^5].

[^5]: This is equivalent to `lazy.nvim`'s `VeryLazy` event.

#### Examples

```lua
require("lze").load {
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
        "sweetie.nvim",
        -- lazy-load when setting the `sweetie` colorscheme
        colorscheme = "sweetie",
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

<!-- markdownlint-disable -->
<details>
  <summary>
    <b><a href="https://github.com/savq/paq-nvim">paq-nvim</a> example</b>
  </summary>

  ```lua
  require "paq" {
      { "nvim-telescope/telescope.nvim", opt = true },
      { "NTBBloodBatch/sweetie.nvim", opt = true }
  }

  require("lze").load {
      {
          "telescope.nvim",
          cmd = "Telescope",
      },
      {
          "sweetie.nvim",
          colorscheme = "sweetie",
      },
  }
  ```

</details>

<details>
  <summary>
    <b><a href="https://wiki.nixos.org/wiki/Neovim">Nix (Home Manager) example</a></b>
  </summary>

  ```nix
  programs.neovim = {
    enable = true;
    plugins = with pkgs.vimPlugins [
      lze
      {
        plugin = pkgs.vimPlugins.telescope-nvim;
        config = ''
          require("lze").load {
            "telescope.nvim",
            cmd = "Telescope",
          }
        '';
        type = "lua";
        optional = true;
      }
      {
        plugin = pkgs.vimPlugins.sweetie-nvim;
        config = ''
          require("lze").load {
            "sweetie.nvim",
            colorscheme = "sweetie",
          }
        '';
        type = "lua";
        optional = true;
      }
    ];
  };
  ```

</details>
<!-- markdownlint-restore -->

### Structuring Your Plugins

As is the case with `lazy.nvim`, you can also split your plugin specs
into multiple files.
Instead of passing a spec table to `require('lze').load()`, you can use a Lua module.
The function will merge specs from the **module** and any top-level **sub-modules**
together in the final spec, so it is not needed to add `require` calls
in your main plugin file to the other files.

Example:

- `~/.config/nvim/init.lua`

```lua
require("lze").load("plugins")
```

- `~/.config/nvim/lua/plugins.lua` or `~/.config/nvim/lua/plugins/init.lua`
  **(this file is optional)**

```lua
return {
    { "sweetie.nvim" },
    { "telescope.nvim", cmd = "Telescope" },
}
```

- `lze` will automatically merge any Lua file in `~/.config/nvim/lua/plugins/*.lua`
  with the main plugin spec[^6].

[^6]: It *does not* merge multiple specs for the same plugin
    from different files and WILL throw an error.

Example structure:

```sh
── nvim
  ├── lua
  │  └── plugins # Your plugin specs go here.
  │     └── init.lua # Optional top-level module returning a list of specs
  │     └── neorg.lua # Single spec
  │     └── telescope/init.lua # Single spec
  ├── init.lua
```

Or

```sh
── nvim
  ├── lua
  │  └── plugins.lua # Optional top-level module returning a list of specs
  ├── init.lua
```

### Custom Handlers

You may register your own handlers to lazy-load plugins via
other triggers not already covered by the plugin spec.

> [!WARNING]
> You must register ALL handlers before calling `require('lze').load`,
> because they will not be retroactively applied to
> the `load` calls that occur before they are registered.

```lua
---@param handlers lze.Handler[]|lze.Handler|lze.HandlerSpec[]|lze.HandlerSpec
---@return string[] handlers_registered
require("lze").register_handlers({
    require("my_handlers.module1"),
    require("my_handlers.module2"),
    {
        handler = require("my_handlers.module3"),
        enabled = true,
    },
})
```

You may call this function multiple times,
each call will append the new handlers (if enabled) to the end of the list.

The handlers define the fields you may use for lazy loading,
with the fields like `ft` and `event` that exist
in the default plugin spec being defined by the handlers defined in `require('lze').default_handlers`.

The order of this list of handlers is important.

It is the same as the order in which their `add`,
`before`, and `after` hooks are called.

If you wish to redefine a default handler, or change the order
in which the default handlers are called, there exists a `require('lze').clear_handlers()`
function for this purpose. It also returns the removed handlers.

Here is an example of how would add a custom handler BEFORE the default list of handlers:

```lua
require('lze').clear_handlers() -- clear_handlers removes ALL handlers
-- and now we can register them in any order we want.
require("lze").register_handlers(require("my_handlers.b4_defaults"))
require("lze").register_handlers(require("lze").default_handlers)
```

Again, this is important:

> [!WARNING]
> You must register ALL handlers before calling `require('lze').load`,
> because they will not be retroactively applied to
> the `load` calls that occur before they are registered.

#### `lze.Handler`

<!-- markdownlint-disable MD013 -->
| Property | Type | Description |
|----------|------|-------------|
| spec_field | `string` | the `lze.PluginSpec` field defined by the handler |
| add | `fun(plugin: lze.Plugin)` | adds a plugin to the handler |
| before | `fun(plugin: lze.Plugin)?` | called before a plugin's load implementation has been called |
| after | `fun(plugin: lze.Plugin)?` | called after a plugin's load implementation has been called |
<!-- markdownlint-enable MD013 -->

#### `lze.HandlerSpec`

<!-- markdownlint-disable MD013 -->
| Property | Type | Description |
|----------|------|-------------|
| handler | `lze.Handler` | the handler to be added |
| enabled | ``boolean?` or `fun():boolean`` | whether the handler should be active |
<!-- markdownlint-enable MD013 -->

#### Writing Custom Handlers

When writing custom handlers, via your `add` function
you will have the opportunity to receive every plugin
added via `require('lze').load` before any loading hooks
are called from any plugin specs added by that `load` call.

You are then in control of keeping track of it and loading it when desired.

You do this loading with the following function:

```lua
  ---@type fun(plugin_names: string | string[])
  require('lze').trigger_load(plugins_names)
```

The function accepts plugin names and will only
do anything the first time it is called.

It will call the handler's `before` function (if it exists) after the `before` hooks,
and before `load` of the [Plugin's Spec](#plugin-spec).

It will call the handler's `after` function after `load` of the [Plugin's Spec](#plugin-spec).

> [!TIP]
> You should delete the plugin from your handler's state
> in either the `before` or `after` hooks
> so that you dont have to carry around
> unnecessary state and increase your chance of error and your memory usage.

There is also a `require('lze').force_load` with the same signature
***for testing purposes only***.
Using it is not recommended and is likely to break things (for obvious reasons).

## :green_heart: Contributing

All contributions are welcome!
See [CONTRIBUTING.md](./CONTRIBUTING.md).

## :book: License

This library is [licensed](./LICENSE) according to GPL version 2
or (at your option) any later version.

<!-- MARKDOWN LINKS & IMAGES -->
[neovim-shield]: https://img.shields.io/badge/NeoVim-%2357A143.svg?&style=for-the-badge&logo=neovim&logoColor=white
[neovim-url]: https://neovim.io/
[lua-shield]: https://img.shields.io/badge/lua-%232C2D72.svg?style=for-the-badge&logo=lua&logoColor=white
[lua-url]: https://www.lua.org/
<!-- [luarocks-shield]:
https://img.shields.io/luarocks/v/neorocks/lz.n?logo=lua
&color=purple&style=for-the-badge -->
<!-- [luarocks-url]: https://luarocks.org/modules/username/lze -->
