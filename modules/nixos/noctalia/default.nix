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
          ".config/face.jpg".source = ./avatar.jpg;
          ".config/wallpaper.svg".source = ./wallpaper.svg;
        };
      }
    )
  ];
}
