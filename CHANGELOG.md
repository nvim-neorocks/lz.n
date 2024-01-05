<!-- markdownlint-disable -->
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [4.0.0](https://github.com/mrcjkb/nvim-lua-nix-plugin-template/compare/v3.1.0...v4.0.0) (2024-01-05)


### ⚠ BREAKING CHANGES

* replace nixpkgs-fmt with alejandra

### Features

* add docgen workflow ([190f1f9](https://github.com/mrcjkb/nvim-lua-nix-plugin-template/commit/190f1f96b1035f5d57210f3b94cf8ebd5722f876))
* add lua-ls to pre-commit-hooks-nix ([05a35aa](https://github.com/mrcjkb/nvim-lua-nix-plugin-template/commit/05a35aa69f798386b326d902343d8d1f9421dea4))
* add luarocks package + split out type checks ([144fdf0](https://github.com/mrcjkb/nvim-lua-nix-plugin-template/commit/144fdf0c9d5244c08b593b4f46d28aee28ea1960))
* add review-checklist workflow ([6bdc4ec](https://github.com/mrcjkb/nvim-lua-nix-plugin-template/commit/6bdc4ec1e43b57489af711e4c5b71659ab9b0d9c))
* **nix:** use test suite as base for devShell ([446a48f](https://github.com/mrcjkb/nvim-lua-nix-plugin-template/commit/446a48fdfd5ea95942762ce822ae0b57d6c3ffc3))
* switch from flake-utils to flake-parts ([1b35d07](https://github.com/mrcjkb/nvim-lua-nix-plugin-template/commit/1b35d07eb215329ade4ada403c18c235b2ab7d7a))
* use neorocksTest + bump dependencies ([b604362](https://github.com/mrcjkb/nvim-lua-nix-plugin-template/commit/b604362c0d63d503b82ae35c55fb2b6c3cf9cde7))
* use release-please workflow ([c11046f](https://github.com/mrcjkb/nvim-lua-nix-plugin-template/commit/c11046f975340471a67bebb336f46d988a862647))


### Bug Fixes

* correct typo ([a6e9f13](https://github.com/mrcjkb/nvim-lua-nix-plugin-template/commit/a6e9f13a212391be752c29f19f80202738862c68))
* luarocks upload workflow ([01ba07b](https://github.com/mrcjkb/nvim-lua-nix-plugin-template/commit/01ba07b7621f6d53b75380ad898a90f5106a66ee))
* markdownlint can fail on changelog ([34ad340](https://github.com/mrcjkb/nvim-lua-nix-plugin-template/commit/34ad340b12e5cb73332561a8c32a4a0e7b514442))
* type checks for tests ([777091b](https://github.com/mrcjkb/nvim-lua-nix-plugin-template/commit/777091bd9b5031a97a41c3b257790b3c4de2209e))


### Styles

* replace nixpkgs-fmt with alejandra ([eb199e0](https://github.com/mrcjkb/nvim-lua-nix-plugin-template/commit/eb199e06f3ccb2088610043a9ba154482887afe8))

## [Unreleased]

## [3.1.0] - 2023-09-05

### Added

- Use `neorocksTest`.

### Changed

- Bump `luarocks-tag-release` version.

### Fixed

- Fail release if changelog entry doesn't exist.

## [3.0.0] - 2023-08-16

### Fixed

- Luarocks Upload workflow.

### Changed

- Loosen license restrictions to allow any OSI approved open source derivations.
- Switch from `flake-utils` to `flake-parts`.

### Added

- More pre-commit-hooks and linters.
- `luarocks-tag-release` workflow.
- Add lua-ls pre-commit checks.

### Changed

- Remove `cachix-action` from workflow.

## [2.0.0] - 2023-01-02

### Changed

- Replace `nixpkgs-fmt` with `alejandra`.

## [1.0.0] - 2022-10-20

### Added

- Initial release
