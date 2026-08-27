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
    immich
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

  # Temporary stand-in for /mnt/photos until a real disk is mounted there.
  # Lives on the root disk, not on /tmp: immich-server/immich-machine-learning
  # run with PrivateTmp=true, so a path under /tmp is invisible to them.
  systemd.tmpfiles.rules = [
    "d /mnt/photos 0750 immich immich -"
  ];

  services.caddy = {
    enable = true;
    virtualHosts."hello-world.toniogela.dev".extraConfig = ''
      respond "Hello, world!"
    '';
    virtualHosts."photos.toniogela.dev".extraConfig = ''
      reverse_proxy localhost:2283
    '';
  };

  networking.firewall.trustedInterfaces = [ "tailscale0" ];

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
