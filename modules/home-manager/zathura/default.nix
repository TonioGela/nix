{
  pkgs,
  pkgsUnstable,
  lib,
  ...
}:
{
  home = {
    packages = [
      (pkgsUnstable.zathuraPkgs.overrideScope (
        _: prev: {
          zathura_core = prev.zathura_core.overrideAttrs (old: {
            mesonFlags = old.mesonFlags ++ [
              "-Dtests-x11=disabled"
              "-Dtests-wayland=disabled"
            ];
          });
        }
      )).zathuraWrapper
    ];
    file.".config/zathura/zathurarc".source = ./zathurarc;
  };

  xdg.mimeApps = lib.mkIf pkgs.stdenv.isLinux {
    enable = true;
    defaultApplications = {
      "application/pdf" = "org.pwmt.zathura-pdf-mupdf.desktop";
    };
  };
}
