{ pkgs, ... }:
{
  home.packages = [
    (pkgs.symlinkJoin {
      name = "minesweep";
      paths = [ pkgs.minesweep-rs ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/minesweep --add-flags "-c 12 -r 12 -n 16"
      '';
    })
  ];
}
