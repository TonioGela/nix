{ config, ... }:
{
  home.file = {
    ".face".source = ./avatar.jpg;
    ".config/niri/config.kdl".source = ./niri.kdl;
    ".config/.wallpapers/wallpaper.svg".source = ./wallpaper.svg;
    ".config/kitty/kitty.conf".source = ./kitty.conf;
    "notes.md".source = config.lib.file.mkOutOfStoreSymlink ./notes.md;
    ".config/noctalia/settings.json".source =
      config.lib.file.mkOutOfStoreSymlink ./noctalia-settings.json;
  };
}
