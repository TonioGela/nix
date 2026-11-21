{ lib, pkgs, ... }:
{
  config = lib.mkIf pkgs.stdenv.isLinux {
    home.packages = [
      (pkgs.writeShellScriptBin "gif" ''
    out=''${1:-out}
    ${lib.getExe pkgs.gpu-screen-recorder} -w portal -f 30 -o "$out.mp4" || true
    ${lib.getExe pkgs.ffmpeg} -loglevel error -y -i "$out.mp4" -vf "fps=15,scale=800:-1:flags=lanczos,split[a][b];[a]palettegen[p];[b][p]paletteuse" "$out.gif"
  '')
    ];
  };
}
