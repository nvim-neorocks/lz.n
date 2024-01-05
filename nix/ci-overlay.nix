# Add flake.nix test inputs as arguments here
{
  self,
  neodev-nvim,
  plugin-name,
}: final: prev:
with final.lib;
with final.stdenv; let
  nvim-nightly = final.neovim-nightly;

  neodev-plugin = final.pkgs.vimUtils.buildVimPlugin {
    name = "neodev.nvim";
    src = neodev-nvim;
  };

  mkNeorocksTest = {
    name,
    nvim ? final.neovim-unwrapped,
    extraPkgs ? [],
  }: let
    nvim-wrapped = final.pkgs.wrapNeovim nvim {
      configure = {
        packages.myVimPackage = {
          start = [
            # Add plugin dependencies that aren't on LuaRocks here
          ];
        };
      };
    };
  in
    final.pkgs.neorocksTest {
      inherit name;
      pname = plugin-name;
      src = self;
      neovim = nvim-wrapped;

      # luaPackages = ps: with ps; [];
      # extraPackages = [];

      preCheck = ''
        export HOME=$(realpath .)
      '';

      buildPhase = ''
        mkdir -p $out
        cp -r tests $out
      '';
    };

  docgen = final.writeShellApplication {
    name = "docgen";
    runtimeInputs = with final; [
      lemmy-help
    ];
    text = ''
      mkdir -p doc
      # TODO: Update this!
      lemmy-help lua/rocks/{init,commands,config/init}.lua > doc/nvim-plugin.txt
    '';
  };
in {
  nvim-stable-tests = mkNeorocksTest {name = "neovim-stable-tests";};
  nvim-nightly-tests = mkNeorocksTest {
    name = "neovim-nightly-tests";
    nvim = nvim-nightly;
  };
  inherit
    neodev-plugin
    docgen
    ;
}
