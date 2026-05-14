{ pkgs, ... }:
{
  home = {
    packages = [ pkgs.zathura ];
    file.".config/zathura/zathurarc".source = ./zathurarc;
  };
}
