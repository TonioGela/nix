let
  pins = import ./npins;
  sources = {
    pkgs = import pins.nixpkgs { config.allowUnfree = true; };
    pkgsUnstable = import pins.nixpkgs-unstable { config.allowUnfree = true; };
    nixos = import (pins.nixpkgs + "/nixos");
    homeManager = import (pins.home-manager + "/nixos");
    fw13-hardware = import (pins.nixos-hardware + "/framework/13-inch/amd-ai-300-series");
    diskoModule = pins.disko + "/module.nix";
    compat = import pins.flake-compat;
    noctalia = pins.noctalia-shell;
    nix-index-database = pins.nix-index-database + "/nixos-module.nix";
  };
  modules = {
    nixos = import ./modules/nixos { inherit sources; };
    home-manager = import ./modules/home-manager;
  };
  builders = {
    nixos =
      system: config:
      import (pins.nixpkgs + "/nixos") {
        inherit system;
        configuration = {
          imports = [
            (import config { inherit sources modules; })
            sources.homeManager
          ];
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            sharedModules = [
              {
                _module.args = {
                  pkgsUnstable = sources.pkgsUnstable;
                };
                home.enableNixpkgsReleaseCheck = true;
                programs.home-manager.enable = true;
                home.stateVersion = "25.11";
              }
            ];
          };
        };

      };
  };
in
{
  framework = builders.nixos "x86_64-linux" ./machines/framework.nix;
}
