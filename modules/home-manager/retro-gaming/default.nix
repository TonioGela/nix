{
  pkgs,
  pkgsUnstable,
  lib,
  config,
  ...
}:
let
  es_de_version = "357718352";
  es_de_home_path = "$HOME/.config/"; # it will use an ES-DE folder
  cores_path = "/etc/profiles/per-user/toniogela/lib/retroarch/cores"; # This is necessary as I use home.useUserPackages

  emulationStationDE-unwrapped = pkgs.appimageTools.wrapType2 {
    name = "emulationstation-de-unwrapped";
    pname = "emulationstation-de";
    version = es_de_version;
    src = pkgs.fetchurl {
      url = "https://gitlab.com/es-de/emulationstation-de/-/package_files/${es_de_version}/download";
      sha256 = "sha256-q8KZmhI4X4V3W9P5hvqJHHa2nfN5H3wS5MeDzzw2MPU=";
    };
  };
  # This wrapping is necessary with my configuration as libgit2 used by es-de
  # does not support zdiff3 and downloading themes is impossible
  emulationStationDE = pkgs.writeShellScriptBin "emulationstation-de" ''
    EMPTY_DIR=$(mktemp -d)
    trap 'rm -rf "$EMPTY_DIR"' EXIT

    ARGS=(--dev-bind / /)
    [ -e "$HOME/.config/git" ] && ARGS+=(--bind "$EMPTY_DIR" "$HOME/.config/git")

    exec ${lib.getExe pkgs.bubblewrap} "''${ARGS[@]}" \
      ${lib.getExe emulationStationDE-unwrapped} --home ${es_de_home_path} "$@"
  '';
in
{
  programs.retroarch = {
    enable = true;
    package = pkgsUnstable.retroarch-bare;
    settings = import ./retroarch-settings.nix { pkgs = pkgsUnstable; };
    # Every core.<something>.enable uses pkgs.libretro.<something>
    cores = {
      mesen.enable = true;
      mgba.enable = true;
      snes9x.enable = true;
      gambatte.enable = true;
      swanstation.enable = true;
      dosbox-pure.enable = true;
    };
  };

  home.file.".config/retroarch/system".source = ./bios;
  # Saves/states synced through eddie with the trimui (see modules/nixos/syncthing.nix)
  services.syncthing = {
    enable = true;
    settings = {
      devices.eddie.id = "ITEN6PF-J4WDTDK-3RLD4ZB-7RSI4FG-JVK4KMU-2MOJTL3-3OYH7ON-JZAMZQB";
      folders.retroarch-saves = {
        path = "${config.home.homeDirectory}/.config/retroarch/saves";
        devices = [ "eddie" ];
      };
    };
  };

  home.packages = [ emulationStationDE ];

  home.file.".config/ES-DE/custom_systems/es_find_rules.xml".text = ''
    <ruleList>
        <core name="RETROARCH">
            <rule type="corepath">
            <entry>${cores_path}</entry>
            </rule>
        </core>
    </ruleList>
  '';

  home.file.".config/ES-DE/settings/es_settings.xml".source =
    config.lib.file.mkOutOfStoreSymlink ./es_settings.xml;

  xdg.desktopEntries.emulationstation-de = lib.mkIf pkgs.stdenv.isLinux {
    name = "EmulationStation DE";
    exec = "emulationstation-de %U";
    categories = [ "Game" ];
    icon = ./ES-DE.ico;
    comment = "EmulationStation Desktop Edition";
  };
}
