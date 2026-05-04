let
  pins = import ./npins;
  sources = {
    pkgs = import pins.nixpkgs { config.allowUnfree = true; };
    pkgsUnstable = import pins.nixpkgs-unstable { config.allowUnfree = true; };
    homeManager = import (pins.home-manager + "/nixos");
    fw13-hardware = import (pins.nixos-hardware + "/framework/13-inch/amd-ai-300-series");
    disko = pins.disko + "/module.nix";
    noctalia = (import pins.flake-compat { src = pins.noctalia-shell; }).outputs.nixosModules.default;
    nix-index-database = import (pins.nix-index-database + "/nixos-module.nix");
    nixosBuilder = import (pins.nixpkgs + "/nixos");
    homeManagerBuilder = import (pins.home-manager + "/modules");
  };
  modules = {
    nixos = import ./modules/nixos { inherit sources; };
    home-manager = import ./modules/home-manager;
  };
  builders = import ./builders.nix { inherit sources modules; };
in
{
  framework = builders.nixos "x86_64-linux" ./machines/framework.nix;
  # work = builders.home-manager ./machines/work.nix;
}
