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
  builders = {
    nixos =
      system: config:
      import (pins.nixpkgs + "/nixos") {
        configuration = import config { inherit sources; };
        inherit system;
      };
  };
in
{
  framework = builders.nixos "x86_64-linux" ./machines/framework.nix;
}
