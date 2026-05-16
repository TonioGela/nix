{ pkgs, ... }:
{
  home.packages = [ pkgs.mpv ];
  home.file.".config/mpv/mpv.conf".text = ''
    hwdec=auto
  '';
}
