{ pkgs, lib, ... }:
{
  home = {
    packages = [ pkgs.zathura ];
    file.".config/zathura/zathurarc".source = ./zathurarc;
  };

  xdg.mimeApps = lib.mkIf pkgs.stdenv.isLinux {
    enable = true;
    defaultApplications = {
      "application/pdf" = "org.pwmt.zathura.desktop";
    };
  };
}
