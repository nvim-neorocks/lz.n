{
  name,
  self,
}: final: prev: let
  packageOverrides = luaself: luaprev: {
    lz-nvim = luaself.callPackage ({buildLuarocksPackage}:
      buildLuarocksPackage {
        pname = name;
        version = "scm-1";
        knownRockspec = "${self}/lz.n-scm-1.rockspec";
        src = self;
      }) {};
  };

  lua5_1 = prev.lua5_1.override {
    inherit packageOverrides;
  };
  lua51Packages = final.lua5_1.pkgs;

  lz-nvim = final.neovimUtils.buildNeovimPlugin {
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
      inherit lz-nvim;
    };
}
