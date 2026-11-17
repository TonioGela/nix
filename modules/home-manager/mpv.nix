{ pkgs, ... }:
{
  programs.mpv = {
    enable = true;
    scripts = [
      pkgs.mpvScripts.mpris
      pkgs.mpvScripts.autosubsync-mpv
      # ponytail: hardcoded start res is 192x108; bump to 1080p (y/h still adjust live)
      # auto-copy keeps GPU decoding but hands v360 frames in RAM, instead of full CPU decode
      (pkgs.mpvScripts.vr-reversal.overrideAttrs {
        postPatch = ''
          substituteInPlace 360plugin.lua \
            --replace-fail 'local res  = 1.0' 'local res  = 10.0' \
            --replace-fail 'mp.set_property("hwdec", "no")' 'mp.set_property("hwdec", "auto-copy")'
        '';
      })
    ];
    config.hwdec = "auto";
  };
}
