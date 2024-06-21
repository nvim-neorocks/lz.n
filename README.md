# :sloth: lz.n

[![Neovim][neovim-shield]][neovim-url]
[![Lua][lua-shield]][lua-url]
[![LuaRocks][luarocks-shield]][luarocks-url]

A dead simple lazy-loading Lua library for Neovim plugins.

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
  - Colorscheme events
- Works with:
  - Neovim's built-in `:h packpath` (`:h packadd`)
  - Any plugin manager that supports manually lazy-loading
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
  - `lazy.vim` completely disables and takes over Neovim's
    built-in loading mechanisms, including
    adding a plugin's API (`lua`, `autoload`, ...)
    to the runtimepath.
    `lz.n` doesn't.
    Its only concern is plugin initialization, which is
    the bulk of the startup overhead.
  - Automatic lazy-loading of Lua modules on `require`.
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
vim.g.lz_n = {
    ---@type fun(name: string)
    load = vim.cmd.packadd,
}
```

## :books: Usage

```lua
require("lz.n").load(plugins)
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
> loading.

### Plugin spec

<!-- markdownlint-disable MD013 -->
| Property         | Type | Description | `lazy.nvim` eqivalent |
|------------------|------|-------------|-----------------------|
| **[1]** | `string` | The plugin's name (not the module name). This is what is passed to the `load(name)` function. | `name`[^1] |
| **enabled** | `boolean?` or `fun():boolean` | When `false`, or if the `function` returns false, then this plugin will not be included in the spec. | `enabled` |
| **beforeAll** | `fun(lz.n.Plugin)?` | Always executed before any plugins are loaded. | `init` |
| **before** | `fun(lz.n.Plugin)?` | Executed before a plugin is loaded. | None |
| **after** | `fun(lz.n.Plugin)?` | Executed after a plugin is loaded. | `config` |
| **event** | `string?` or `{event?:string\|string[], pattern?:string\|string[]}\` or `string[]` | Lazy-load on event. Events can be specified as `BufEnter` or with a pattern like `BufEnter *.lua`. | `event` |
| **cmd** | `string?` or `string[]` | Lazy-load on command. | `cmd` |
| **ft** | `string?` or `string[]` | Lazy-load on filetype. | `ft` |
| **keys** | `string?` or `string[]` or `lz.n.KeysSpec[]` | Lazy-load on key mapping. | `keys` |
| **colorscheme** | `string?` or `string[]` | Lazy-load on colorscheme. | None. `lazy.nvim` lazy-loads colorschemes automatically[^2]. |
| **priority** | `number?` | Only useful for **start** plugins (not lazy-loaded) to force loading certain plugins first. Default priority is `50` (or `1000` if `colorscheme` is set). | `priority` |
| **load** | `fun(string)?` | Can be used to override the `vim.g.lz_n.load()` function for an individual plugin. | None. |
<!-- markdownlint-enable MD013 -->

[^1]: In contrast to `lazy.nvim`'s `name` field, a `lz.n.PluginSpec`'s `name` *is not optional*.
      This is because `lz.n` is not a plugin manager and needs to be told which
      plugins to load.
[^2]: The reason this library doesn't lazy-load colorschemes automatically is that
      it would have to know where the plugin is installed in order to determine
      which plugin to load.

### User events

- `DeferredUIEnter`: Triggered when `load()` is done and after `UIEnter`.
  Can be used as an `event` to lazy-load plugins that are not immediately needed
  for the initial UI[^3].

[^3]: This is equivalent to `lazy.nvim`'s `VeryLazy` event.

#### Examples

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
      { "nvim-telescope/telescope.nvim", opt = true }
      { "NTBBloodBatch/sweetie.nvim", opt = true }
  }

  require("lz.n").load {
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
      lz-n
      {
        plugin = pkgs.vimPlugins.telescope-nvim;
        config = ''
          require("lz.n").load {
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
          require("lz.n").load {
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
  with the main plugin spec[^4].

[^4]: It *does not* merge multiple specs for the same plugin from different files.

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
[luarocks-shield]: https://img.shields.io/luarocks/v/neorocks/lz.n?logo=lua&color=purple&style=for-the-badge
[luarocks-url]: https://luarocks.org/modules/neorocks/lz.n
