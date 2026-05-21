let
  pins = import ./npins;
  sources = {
    pkgs = import pins.nixpkgs { config.allowUnfree = true; };
    pkgsUnstable = import pins.nixpkgs-unstable { config.allowUnfree = true; };
    homeManager = import (pins.home-manager + "/nixos");
    fw13-hardware = import (pins.nixos-hardware + "/framework/13-inch/amd-ai-300-series");
    disko = pins.disko + "/module.nix";
    noctalia = {
      package = sources.pkgs.callPackage (pins.noctalia-shell + "/nix/package.nix") {
        version = sources.pkgs.lib.removePrefix pins.noctalia-shell.release_prefix pins.noctalia-shell.version;
        quickshell = sources.pkgs.callPackage (pins.noctalia-qs + "/nix/package.nix") {
          version = sources.pkgs.lib.removePrefix pins.noctalia-qs.release_prefix pins.noctalia-qs.version;
          gitRev = pins.noctalia-qs.revision;
        };
      };
      nixosModule = import (pins.noctalia-shell + "/nix/nixos-module.nix");
      homeManagerModule = import (pins.noctalia-shell + "/nix/home-module.nix");
    };
    nix-index-database = import (pins.nix-index-database + "/home-manager-module.nix");
    nixosBuilder = import (pins.nixpkgs + "/nixos");
    homeManagerBuilder = import (pins.home-manager + "/modules");
  };
  import-modules = import ./utils/import-modules.nix;
  modules = {
    home-manager = import-modules ./modules/home-manager;
    nixos = import-modules ./modules/nixos;
  };
  builders = import ./utils/builders.nix { inherit sources modules; };
in
{
  framework = builders.nixos "x86_64-linux" ./machines/framework;
  work = builders.home-manager ./machines/work;
}
