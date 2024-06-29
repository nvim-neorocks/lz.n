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
        "aarch64-linux"
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
        };

        type-check-nightly = pre-commit-hooks.lib.${system}.run {
          src = self;
          hooks = {
            lua-ls = {
              enable = true;
              settings.configuration = luarc;
            };
          };
        };

        pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = self;
          hooks = {
            alejandra.enable = true;
            stylua.enable = true;
            luacheck.enable = true;
            editorconfig-checker.enable = true;
            markdownlint = {
              enable = true;
              excludes = [
                "CHANGELOG.md"
              ];
            };
          };
        };

        devShell = pkgs.mkShell {
          name = "lz.n devShell";
          shellHook = ''
            ${pre-commit-check.shellHook}
            ln -fs ${pkgs.luarc-to-json luarc} .luarc.json
          '';
          buildInputs =
            self.checks.${system}.pre-commit-check.enabledPackages
            ++ (with pkgs; [
              lua-language-server
              busted-nlua
            ]);
        };
      in {
        devShells = {
          default = devShell;
          inherit devShell;
        };

        packages = rec {
          default = lz-n-vimPlugin;
          lz-n-luaPackage = pkgs.lua51Packages.lz-n;
          lz-n-vimPlugin = pkgs.vimPlugins.lz-n;
        };

        checks = {
          inherit
            pre-commit-check
            type-check-nightly
            ;
          inherit
            (pkgs)
            nvim-nightly-tests
            ;
        };
      };
      flake = {
        overlays.default = pkg-overlay;
      };
    };
}
