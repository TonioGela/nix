{ sources, ... }:
{
  imports = [
    sources.fw13-hardware
    ./hardware-configuration.nix
    sources.diskoModule
    ./disko.nix
  ];
}
