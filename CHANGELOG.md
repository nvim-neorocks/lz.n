# Changelog

## [2.0.1](https://github.com/nvim-neorocks/lz.n/compare/v2.0.0...v2.0.1) (2024-08-22)


### Bug Fixes

* **loader:** deterministic ordering when loading lists of plugins ([8667b60](https://github.com/nvim-neorocks/lz.n/commit/8667b60015ba0cc67f0a65124755a5911dc1f4b4))

## [2.0.0](https://github.com/nvim-neorocks/lz.n/compare/v1.4.4...v2.0.0) (2024-08-20)


### ⚠ BREAKING CHANGES

* simplify state management + idempotent `trigger_load` ([#56](https://github.com/nvim-neorocks/lz.n/issues/56))

### Features

* simplify state management + idempotent `trigger_load` ([#56](https://github.com/nvim-neorocks/lz.n/issues/56)) ([701d6ac](https://github.com/nvim-neorocks/lz.n/commit/701d6acc030d1ed6ef16b7efe4d752dbf7d7f13b))


### Bug Fixes

* altered loading order for startup plugins ([#49](https://github.com/nvim-neorocks/lz.n/issues/49)) ([50c1454](https://github.com/nvim-neorocks/lz.n/commit/50c145466330c0c5b272fd3904b5655a1613149c))

## [1.4.4](https://github.com/nvim-neorocks/lz.n/compare/v1.4.3...v1.4.4) (2024-08-09)


### Bug Fixes

* colorscheme handler broken for `start` plugins ([#41](https://github.com/nvim-neorocks/lz.n/issues/41)) ([7ba8692](https://github.com/nvim-neorocks/lz.n/commit/7ba8692a5f88c04de5791232887823e0f40f9525))

## [1.4.3](https://github.com/nvim-neorocks/lz.n/compare/v1.4.2...v1.4.3) (2024-07-10)


### Bug Fixes

* spec list with a single plugin spec ignored ([#34](https://github.com/nvim-neorocks/lz.n/issues/34)) ([e0831fe](https://github.com/nvim-neorocks/lz.n/commit/e0831fee3109a56705a6eea896e1d7d5d157a04d))

## [1.4.2](https://github.com/nvim-neorocks/lz.n/compare/v1.4.1...v1.4.2) (2024-06-29)


### Bug Fixes

* **keys:** don't ignore modes that aren't `'n'` ([#28](https://github.com/nvim-neorocks/lz.n/issues/28)) ([8886765](https://github.com/nvim-neorocks/lz.n/commit/8886765a2fcc9b9550dbd2e8d9bb5535f1de290d))

## [1.4.1](https://github.com/nvim-neorocks/lz.n/compare/v1.4.0...v1.4.1) (2024-06-26)


### Bug Fixes

* odd intermittent issue with load function ([#21](https://github.com/nvim-neorocks/lz.n/issues/21)) ([1ac92ff](https://github.com/nvim-neorocks/lz.n/commit/1ac92fff5da1212174956b20383a75b6268c56a7))

## [1.4.0](https://github.com/nvim-neorocks/lz.n/compare/v1.3.2...v1.4.0) (2024-06-24)


### Features

* extend lz.n with custom handlers ([#17](https://github.com/nvim-neorocks/lz.n/issues/17)) ([d61186f](https://github.com/nvim-neorocks/lz.n/commit/d61186fc231797e07986e4dc59f789d8660dc822))

## [1.3.2](https://github.com/nvim-neorocks/lz.n/compare/v1.3.1...v1.3.2) (2024-06-19)


### Bug Fixes

* **event:** broken `DeferredUIEnter` event ([cf11ec2](https://github.com/nvim-neorocks/lz.n/commit/cf11ec2b1696dddd5620a055244cc0860f982677))

## [1.3.1](https://github.com/nvim-neorocks/lz.n/compare/v1.3.0...v1.3.1) (2024-06-19)


### Bug Fixes

* support /nix/store links ([fa625dd](https://github.com/nvim-neorocks/lz.n/commit/fa625dd86414dc830c6c9b7188fe4cd583e664c4))

## [1.3.0](https://github.com/nvim-neorocks/lz.n/compare/v1.2.4...v1.3.0) (2024-06-18)


### Features

* support importing `init.lua` submodules ([5c3c2a1](https://github.com/nvim-neorocks/lz.n/commit/5c3c2a1eb4df0260f9ed738ec321aa85ecf8e0f9))
* support loading plugin spec lists and imports more than once ([d911029](https://github.com/nvim-neorocks/lz.n/commit/d9110299475823eff784a6ccf6aa3f63dea9b295))

## [1.2.4](https://github.com/nvim-neorocks/lz.n/compare/v1.2.3...v1.2.4) (2024-06-17)


### Bug Fixes

* actually support importing plugin specs from files ([5553dc5](https://github.com/nvim-neorocks/lz.n/commit/5553dc52fa696f1e8162329a91e9055ff71020d6))

## [1.2.3](https://github.com/nvim-neorocks/lz.n/compare/v1.2.2...v1.2.3) (2024-06-16)


### Bug Fixes

* colorscheme lists inserted into wrong table ([9fe735e](https://github.com/nvim-neorocks/lz.n/commit/9fe735e6ca5e835f953ab284188cd31322804e43))

## [1.2.2](https://github.com/nvim-neorocks/lz.n/compare/v1.2.1...v1.2.2) (2024-06-16)


### Bug Fixes

* spdx license identifier in release rockspec ([5c71d03](https://github.com/nvim-neorocks/lz.n/commit/5c71d03bfad28298b1a9cf11f7ce134b5ad6318a))

## [1.2.1](https://github.com/nvim-neorocks/lz.n/compare/v1.2.0...v1.2.1) (2024-06-16)


### Bug Fixes

* ensure individual plugins can only be registered once ([47a10af](https://github.com/nvim-neorocks/lz.n/commit/47a10afe2c4eae2d5429864acaba536073f6e089))

## [1.2.0](https://github.com/nvim-neorocks/lz.n/compare/v1.1.0...v1.2.0) (2024-06-16)


### Features

* register individual plugin specs for lazy loading ([b9c03c1](https://github.com/nvim-neorocks/lz.n/commit/b9c03c1ed2fd95abd657a7310310aeee039cd3ec))

## [1.1.0](https://github.com/nvim-neorocks/lz.n/compare/v1.0.0...v1.1.0) (2024-06-15)


### Features

* add `DeferredUIEnter` user event ([0a3b2c5](https://github.com/nvim-neorocks/lz.n/commit/0a3b2c5e12ced350aec9b6dd797b824e7e34e76a))

## 1.0.0 (2024-06-10)


### Features

* add `before` hook ([19beffc](https://github.com/nvim-neorocks/lz.n/commit/19beffc4d943aa29fe1edb459833f008d107b9d8))
* add `PluginSpec.config` ([b52a46c](https://github.com/nvim-neorocks/lz.n/commit/b52a46c624fee24e4ba91a5a29be45c70e45ce5a))
* automatically increase `priority` if `colorscheme` is set ([655ab06](https://github.com/nvim-neorocks/lz.n/commit/655ab06f4686371f07717c915b16eb4b18f6ef31))
* handler for lazy-loading colorschemes ([d4a2eeb](https://github.com/nvim-neorocks/lz.n/commit/d4a2eebb84b1c000a8388e167be3cb8f9d1edfe4))
