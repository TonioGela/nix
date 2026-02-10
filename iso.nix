let
  sources = import ./npins;
  nixpkgs = sources.nixpkgs;
  pkgs = import nixpkgs { };
  nixos = import (nixpkgs + "/nixos");
  installation-cd-minimal = import (
    nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
  );
  compat = import sources.flake-compat;
  disko = compat { src = sources.disko; };
  # channel = import (nixpkgs + "/nixos/modules/installer/cd-dvd/channel.nix");
in
(nixos {
  configuration = {
    imports = [
      installation-cd-minimal
      # <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
    ];

    environment.systemPackages = [
      pkgs.neovim
      disko.outputs.packages.x86_64-linux.disko
      pkgs.git
    ];
  };
}).config.system.build.isoImage
