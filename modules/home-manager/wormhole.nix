{ pkgs, ... }:
{
  home.packages = [
    (pkgs.symlinkJoin {
      name = "wormhole";
      paths = [ pkgs.wormhole-rs ];
      postBuild = ''
        rm $out/bin/wormhole-rs
        ln -s ${pkgs.wormhole-rs}/bin/wormhole-rs $out/bin/wormhole
      '';
    })
  ];
}
