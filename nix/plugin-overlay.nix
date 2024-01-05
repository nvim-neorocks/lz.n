{
  name,
  self,
}: final: prev: let
  packageOverrides = luaself: luaprev: {
    # TODO: Rename
    plugin-template-nvim = luaself.callPackage ({buildLuarocksPackage}:
      buildLuarocksPackage {
        pname = name;
        version = "scm-1";
        # TODO: Set rockspec name
        knownRockspec = "${self}/plugin-template.nvim-scm-1.rockspec";
        src = self;
      }) {};
  };

  lua5_1 = prev.lua5_1.override {
    inherit packageOverrides;
  };
  lua51Packages = final.lua5_1.pkgs;

  # TODO: Rename
  nvim-plugin = final.neovimUtils.buildNeovimPlugin {
    pname = name;
    src = self;
    version = "dev";
  };
in {
  inherit
    lua5_1
    lua51Packages
    ;

  vimPlugins =
    prev.vimPlugins
    // {
      inherit nvim-plugin;
    };
}
