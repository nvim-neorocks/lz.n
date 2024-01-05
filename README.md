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

## Contributing

All contributions are welcome!
See [CONTRIBUTING.md](./CONTRIBUTING.md).

## License

This template is [licensed](./LICENSE) according to GPL version 2
or (at your option) any later version.
