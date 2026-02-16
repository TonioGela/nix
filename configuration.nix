let
  sources = import ./npins;
  nixos = import (sources.nixpkgs + "/nixos");
  actual-configuration = import ./actual-configuration.nix;
in
nixos { configuration = actual-configuration; }
