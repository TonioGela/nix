{ config, ... }:
{
  home.file = {
    ".face".source = ./avatar.jpg;
    ".config/niri/config.kdl".source = ./niri.kdl;
    ".config/.wallpapers/wallpaper.svg".source = ./wallpaper.svg;
    ".config/noctalia/settings.json".source =
      config.lib.file.mkOutOfStoreSymlink ./noctalia-settings.json;
    ".config/zathura/zathurarc".source = ./zathurarc;
  };
}
