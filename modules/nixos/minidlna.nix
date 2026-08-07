{ lib, ... }: {
  services.minidlna = {
    enable = true;
    openFirewall = true;
    settings = {
      media_dir = [ "V,/home/toniogela/Videos" ]; # V=video, A=audio, P=foto
      friendly_name = "NixOS-DLNA";
      inotify = "yes";
      notify_interval = 10;
    };
  };
  systemd.services.minidlna = {
    wantedBy = lib.mkForce [ ];
    serviceConfig = {
      User = lib.mkForce "toniogela";
      Group = lib.mkForce "users";
    };
  };
}
