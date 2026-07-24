{ lib, ... }: {
  services.minidlna = {
    enable = true;
    openFirewall = true;
    settings = {
      media_dir = [ "V,/home/toniogela/Videos" ]; # V=video, A=audio, P=foto
      friendly_name = "NixOS-DLNA";
    };
  };
  systemd.services.minidlna.serviceConfig = {
    User = lib.mkForce "toniogela";
    Group = lib.mkForce "users";
  };
}
