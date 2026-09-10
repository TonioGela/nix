let
  pins = import ./npins;
  sources = rec {
    nix-vscode-extensions = (import pins.nix-vscode-extensions).overlays.default;
    pkgs = import pins.nixpkgs { config.allowUnfree = true; };
    pkgsUnstable = import pins.nixpkgs-unstable { config.allowUnfree = true; };
    homeManager = import (pins.home-manager + "/nixos");
    fw13-hardware = import (pins.nixos-hardware + "/framework/13-inch/amd-ai-300-series");
    disko = pins.disko + "/module.nix";
    noctalia5 = import pins.noctalia { };
    sops = import (pins.sops-nix + "/modules/home-manager/sops.nix");
    lanzaboote = (import pins.lanzaboote { inherit pkgs; }).nixosModules.lanzaboote;
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
  ronnie = builders.nixos "x86_64-linux" ./machines/ronnie;
  darrel = builders.home-manager ./machines/darrel;
  eddie = builders.nixos "x86_64-linux" ./machines/eddie;
  gilderien = builders.nixos "x86_64-linux" ./machines/gilderien;
}
