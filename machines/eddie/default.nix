{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";

  time.timeZone = "Europe/Amsterdam";

  i18n.defaultLocale = "en_US.UTF-8";

  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  users.users.toniogela = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    packages = [ pkgs.tree ];
    openssh = {
      authorizedKeys.keys = [
        # Replace with the output of `ssh-add -L` on your machine
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILWwmMYuP1GUPSBRiven+ia4YQhwoNXNyjw6OOTYL/Md (none)"
      ];
    };
  };

  environment.systemPackages = [
    pkgs.neovim
  ];

  services.openssh = {
    enable = true;
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    ipv4 = true;
    ipv6 = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
  };
}
