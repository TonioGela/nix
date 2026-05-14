let
  pins = import ./npins;
  sources = {
    pkgs = import pins.nixpkgs { config.allowUnfree = true; };
    pkgsUnstable = import pins.nixpkgs-unstable { config.allowUnfree = true; };
    homeManager = import (pins.home-manager + "/nixos");
    fw13-hardware = import (pins.nixos-hardware + "/framework/13-inch/amd-ai-300-series");
    disko = pins.disko + "/module.nix";
    noctalia = (import pins.flake-compat { src = pins.noctalia-shell; }).outputs.nixosModules.default;
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
