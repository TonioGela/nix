{ sources, ... }:
{
  imports = [ sources.noctalia.nixosModule ];
  services.noctalia-shell.enable = true;
  services.noctalia-shell.package = sources.noctalia.package;
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
