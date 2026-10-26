# Free fonts named in https://modernfontstacks.com stacks.
# Apple-only ones (Charter, Iowan, Seravek, Avenir, Optima, Menlo, Didot, ...) ship with macOS.
# ponytail: skipped Charter, nixpkgs only has it as Type1, which Pango/browsers ignore
{ pkgs, ... }:
let
  # P052, Nimbus Sans (Narrow), URW Gothic, URW Bookman, Nimbus Mono PS as OTF (ghostscript.fonts is Type1)
  urw-base35 = pkgs.runCommand "urw-base35-fonts" {
    src = pkgs.fetchFromGitHub {
      owner = "ArtifexSoftware";
      repo = "urw-base35-fonts";
      rev = "20200910";
      hash = "sha256-YQl5IDtodcbTV3D6vtJi7CwxVtHHl58fG6qCAoSaP4U=";
    };
  } "install -Dm444 -t $out/share/fonts/opentype $src/fonts/*.otf";
in
{
  fonts.fontconfig.enable = true;
  home.packages = [
    pkgs.vista-fonts # Calibri, Cambria, Candara, Consolas, Corbel
    pkgs.corefonts # Arial, Georgia, Courier New, Comic Sans MS
    pkgs.ubuntu-classic
    pkgs.dejavu_fonts
    pkgs.source-sans-pro
    pkgs.source-code-pro
    pkgs.montserrat
    pkgs.noto-fonts # Noto Sans, Noto Serif Display
    pkgs.inter
    pkgs.roboto
    pkgs.roboto-slab
    pkgs.cascadia-code
    pkgs.quicksand
    pkgs.comfortaa
    pkgs.smc-manjari
    pkgs.smc-chilanka
    urw-base35
  ];
}
