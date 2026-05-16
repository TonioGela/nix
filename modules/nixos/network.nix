{
  services.resolved.enable = true;
  systemd.services.NetworkManager-wait-online.enable = false;
  networking.networkmanager.enable = true;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
}
