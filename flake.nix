{
  description = "Add laziness to your favourite plugin manager!";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
    };

    neorocks.url = "github:nvim-neorocks/neorocks";

    gen-luarc.url = "github:mrcjkb/nix-gen-luarc-json";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-parts,
    pre-commit-hooks,
    neorocks,
    gen-luarc,
    ...
  }: let
    name = "lz.n";

    pkg-overlay = import ./nix/pkg-overlay.nix {
      inherit name self;
    };
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      perSystem = {
        config,
        self',
        inputs',
        system,
        ...
      }: let
        ci-overlay = import ./nix/ci-overlay.nix {
          inherit self;
          plugin-name = name;
        };

        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            gen-luarc.overlays.default
            neorocks.overlays.default
            ci-overlay
            pkg-overlay
          ];
        };

        luarc = pkgs.mk-luarc {
          nvim = pkgs.neovim-nightly;
          neodev-types = "nightly";
        };

        type-check-nightly = pre-commit-hooks.lib.${system}.run {
          src = self;
          hooks = {
            lua-ls.enable = true;
          };
          settings = {
            lua-ls.config = luarc;
          };
        };

        pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = self;
          hooks = {
            alejandra.enable = true;
            stylua.enable = true;
            luacheck.enable = true;
            editorconfig-checker.enable = true;
            markdownlint.enable = true;
          };
        };

        devShell = pkgs.nvim-nightly-tests.overrideAttrs (oa: {
          name = "lz.n devShell";
          shellHook = ''
            ${pre-commit-check.shellHook}
            ln -fs ${pkgs.luarc-to-json luarc} .luarc.json
          '';
          buildInputs =
            self.checks.${system}.pre-commit-check.enabledPackages
            ++ oa.buildInputs;
        });
      in {
        devShells = {
          default = devShell;
          inherit devShell;
        };

        packages = rec {
          default = lz-n;
          inherit (pkgs.vimPlugins) lz-n;
          inherit (pkgs) docgen;
        };

        checks = {
          inherit
            pre-commit-check
            type-check-nightly
            ;
          inherit
            (pkgs)
            nvim-stable-tests
            nvim-nightly-tests
            ;
        };
      };
      flake = {
        overlays.default = pkg-overlay;
      };
    };
}
