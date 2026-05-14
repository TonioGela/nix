{ sources, ... }:
{
  imports = [ sources.noctalia ];
  services.noctalia-shell.enable = true;
  home-manager.sharedModules = [
    (
      { config, ... }:
      {
        home.file = {
          ".config/noctalia/settings.json".source =
            config.lib.file.mkOutOfStoreSymlink ./noctalia-settings.json;
          ".face".source = ./avatar.jpg;
          ".config/.wallpapers/wallpaper.svg".source = ./wallpaper.svg;
        };
      }
    )
  ];
}
