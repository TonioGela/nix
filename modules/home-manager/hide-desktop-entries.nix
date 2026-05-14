{
  pkgs,
  lib,
  config,
  ...
}:
{

  options = {
    desktopEntriesToHide = pkgs.lib.mkOption {
      type = pkgs.lib.types.listOf (
        pkgs.lib.types.submodule {
          options = {
            filename = pkgs.lib.mkOption { type = pkgs.lib.types.str; };
            name = pkgs.lib.mkOption { type = pkgs.lib.types.str; };
          };
        }
      );
      description = ''
        Entries can be found in:
          - ~/.local/share/applications
          - /run/current-system/sw/share/applications
          - /etc/profiles/per-user/$USER/share/applications
      '';
      default = [ ];
    };
  };

  config.xdg.desktopEntries = lib.mkIf pkgs.stdenv.isLinux (
    builtins.listToAttrs (
      map (m: {
        name = m.filename;
        value = {
          name = m.name;
          noDisplay = true;
        };
      }) config.desktopEntriesToHide
    )
  );
}
