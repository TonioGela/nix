{ pkgs, ... }:

let
  es_de_version = "288156961";
  emulationStationDE = pkgs.appimageTools.wrapType2 {
    name = "emulationstation-de";
    pname = "emulationstation-de";
    version = es_de_version;
    src = pkgs.fetchurl {
      url = "https://gitlab.com/es-de/emulationstation-de/-/package_files/${es_de_version}/download";
      sha256 = "sha256-PGGkTXONVRY9qljt5wcgtCWg32JGDATcI908pYZyNYE=";
    };
  };
in
{
  programs.retroarch = {
    enable = true;
    cores = {
      mgba.enable = true; # Uses pkgs.libretro.mgba
      snes9x.enable = true;
      gambatte.enable = true;
    };
    # settings = {};
  };

  home.packages = [ emulationStationDE ];

  xdg.desktopEntries.emulationstation-de = {
    name = "EmulationStation DE";
    exec = "emulationstation-de %U";
    categories = [ "Game" ];
    comment = "EmulationStation Desktop Edition";
  };
}
