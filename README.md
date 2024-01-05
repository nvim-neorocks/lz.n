# An opinionated Neovim Lua plugin template with a Nix CI

![Neovim](https://img.shields.io/badge/NeoVim-%2357A143.svg?&style=for-the-badge&logo=neovim&logoColor=white)
![Lua](https://img.shields.io/badge/lua-%232C2D72.svg?style=for-the-badge&logo=lua&logoColor=white)
![Nix](https://img.shields.io/badge/nix-0175C2?style=for-the-badge&logo=NixOS&logoColor=white)

This repository is a template for Neovim plugins written in Lua.

## Features

- GitHub Actions workflows with a locally reproducible CI,
using [`nix` flakes](https://nixos.wiki/wiki/Flakes).
- Run tests with both neovim stable and neovim nightly
  using [`neorocksTest`](https://github.com/nvim-neorocks/neorocks).
- Lints and a nix shell with pre-commit-hooks:
  - [`luacheck`](https://github.com/mpeterv/luacheck)
  - [`stylua`](https://github.com/JohnnyMorganz/StyLua)
  - [`lua-language-server` static type checks](https://github.com/LuaLS/lua-language-server/wiki/Diagnosis-Report)
  - [`alejandra`](https://github.com/kamadorueda/alejandra)
  - [`editorconfig-checker`](https://github.com/editorconfig-checker/editorconfig-checker)
  - [`markdownlint`](https://github.com/DavidAnson/markdownlint)
- `vimPlugin` nix flake output.
- Automatically publish tags to [LuaRocks](https://luarocks.org/labels/neovim)
with the [luarocks-tag-release action](https://github.com/nvim-neorocks/luarocks-tag-release).
- Automatic release PRs using [conventional commits](https://conventionalcommits.org/)
  with [release-please](https://github.com/googleapis/release-please).
- Automatically comment PRs with a review checklist.

## Setup

1. Click on [Use this template](https://github.com/MrcJkb/nvim-lua-nix-plugin-template/generate)
to start a repo based on this template. **Do _not_ fork it**.
1. If your plugin depends on other plugins,
add them to [`nvim-wrapped` in the `ci-overlay.nix`](./nix/ci-overlay.nix).
1. Add the name of your plugin to [`flake.nix`](./flake.nix).
1. Add [`plenary.nvim`](https://github.com/nvim-lua/plenary.nvim) specs
to the `tests` directory.
1. Create a [LuaRocks API key](https://luarocks.org/settings/api-keys).
1. Add the API key to the repository's
[GitHub Actions secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets#creating-encrypted-secrets-for-a-repository).
1. Text that needs to be updated is marked with `TODO:` comments.
1. Rename [`plugin-template.nvim-scm-1.rockspec`](./plugin-template.nvim-scm-1.rockspec)

## Contributing

All contributions are welcome!
See [CONTRIBUTING.md](./CONTRIBUTING.md).

## License

This template is [licensed according to GPL version 2](./LICENSE),
with the following exception:

The license applies only to the Nix CI infrastructure provided by this template
repository, including any modifications made to the infrastructure.
Any software that uses or is derived from this template may be licensed under any
[OSI approved open source license](https://opensource.org/licenses/),
without being subject to the GPL version 2 license of this template.
