# Syncthing hub for retroarch saves/states, GUI served by caddy at retroarch.toniogela.dev
{ config, ... }:
let
  devices = {
    ronnie.id = "423YSLJ-3HHBW26-VNQ25BO-EOYUNM6-HOSONDK-XXSZ272-3C24PLO-NUJE4A6";
    trimui.id = "TJO4ZXT-QMWB2DG-XKXHUHP-HPY2AWB-SNCMFM6-LRQT2BO-S6CAMRY-EXHGCAR";
  };
in
{
  # Reuses the old webdav credentials for the GUI login
  sops.secrets.webdav-password.owner = "toniogela";

  services.syncthing = {
    enable = true;
    user = "toniogela";
    group = "users";
    dataDir = "/home/toniogela/retroarch";
    configDir = "/home/toniogela/.local/state/syncthing";
    guiAddress = "127.0.0.1:8384";
    guiPasswordFile = config.sops.secrets.webdav-password.path;
    openDefaultPorts = true;
    settings = {
      inherit devices;
      gui.user = "retroarch";
      # Knulli layout: saves/<system>/, states alongside the saves
      folders.retroarch-saves = {
        path = "/home/toniogela/retroarch/saves";
        devices = builtins.attrNames devices;
      };
    };
  };
}
