{ sources, ... }:
let
  fw13-hardware = import (sources.nixos-hardware + "/framework/13-inch/amd-ai-300-series");
  diskoModule = sources.disko + "/module.nix";
in
{
  imports = [
    fw13-hardware
    ./hardware-configuration.nix
    diskoModule
    ./disko.nix
  ];
}
