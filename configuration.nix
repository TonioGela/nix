# The first activation after a reinstallation requires
# `nh os switch -f ~/.config/nixos/configuration.nix`
# Remember to re-clone this repo in ~/.config/nixos
# and create a symlink with `sudo ln -s ~/.config/nixos /etc/nixos`
let
  sources = import ./npins;
  nixos = import (sources.nixpkgs + "/nixos");
  actual-configuration = import ./actual-configuration.nix;
in
nixos { configuration = actual-configuration; }
