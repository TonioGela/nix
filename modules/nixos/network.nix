{
  services.resolved = {
    enable = true;
    # Avahi takes care of multicastDNS
    extraConfig = ''
      MulticastDNS=no
      LLMNR=no
    '';
  };
  systemd.services.NetworkManager-wait-online.enable = false;
  networking.networkmanager.enable = true;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
}
