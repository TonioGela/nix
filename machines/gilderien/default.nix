{
  modulesPath,
  sources,
  modules,
  ...
}:
{
  imports = with modules.nixos; [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    sources.disko
    ./disko.nix
    passwordless-sudoer
    ssh-keys
    tailscale
  ];

  boot.loader.grub = {
    # no need to set devices, disko adds every disk with an EF02 partition already
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  zramSwap.enable = true;

  networking.hostName = "gilderien";
  networking.useDHCP = true;

  services.openssh.enable = true;
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  passwordlessSudoer = "toniogela";

  tailscale.routingFeatures = "client";
}
