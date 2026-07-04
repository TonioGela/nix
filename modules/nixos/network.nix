{
  services.resolved = {
    enable = true;
    # Avahi takes care of multicastDNS
    settings.Resolve = {
      MulticastDNS = false;
      LLMNR = false;
    };
  };
  systemd.services.NetworkManager-wait-online.enable = false;
  networking.networkmanager.enable = true;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
}
