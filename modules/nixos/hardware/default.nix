{ sources, ... }:
{
  imports = [
    sources.fw13-hardware
    ./hardware-configuration.nix
    sources.disko
    ./disko.nix
  ];

  boot.loader.efi.canTouchEfiVariables = true;
  services.fwupd.enable = true;
  environment.systemPackages = [ sources.pkgs.framework-tool-tui ];

  hardware = {
    bluetooth.enable = true;
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    enableAllFirmware = true;
    enableRedistributableFirmware = true;
  };
}
