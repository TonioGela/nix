{
  pkgs,
  pkgsUnstable,
  modules,
  ...
}:
{
  imports = with modules.nixos; [
    ./hardware
    de-channel
    passwordless-sudoer
    ssh-keys
    tailscale
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgsUnstable.linuxPackages;

  networking.hostName = "eddie";
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  time.timeZone = "Europe/Rome";
  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.extraLocales = [ "it_IT.UTF-8/UTF-8" ];
  passwordlessSudoer = "toniogela";

  environment.systemPackages = [
    pkgs.git
    pkgs.neovim
    pkgsUnstable.nh
    pkgsUnstable.npins
  ];

  services.openssh.enable = true;

  tailscale.routingFeatures = "server";

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
}
