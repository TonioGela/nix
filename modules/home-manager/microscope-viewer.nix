# Viewer for the non-UVC "Geek szitman supercamera" USB microscope (0329:2022)
# On NixOS it also needs a udev rule granting access to the device, see machines/ronnie
{ pkgs, lib, ... }:
let
  supercamera = pkgs.python3Packages.buildPythonPackage rec {
    pname = "supercamera";
    version = "0.1.0";
    pyproject = true;
    src = pkgs.fetchPypi {
      inherit pname version;
      hash = "sha256-6RanjQvClzcISncDqou1RTU+TyUSwItYShdkdgTBj00=";
    };
    build-system = [ pkgs.python3Packages.hatchling ];
    dependencies = with pkgs.python3Packages; [
      pyusb
      pillow
    ];
    pythonImportsCheck = [ "supercamera" ];
  };

  python = pkgs.python3.withPackages (_: [ supercamera ]);

  desktopItem = pkgs.makeDesktopItem {
    name = "microscope-viewer";
    desktopName = "Microscope Viewer";
    exec = "microscope-viewer";
    icon = "microscope-viewer";
    categories = [ "Graphics" ];
  };

  microscope-viewer = pkgs.stdenvNoCC.mkDerivation {
    pname = "microscope-viewer";
    version = "1.0.0-unstable-2026-05-28";
    src = pkgs.fetchFromGitHub {
      owner = "JacobFV";
      repo = "microscope-viewer";
      rev = "910dcff99be8071816116624283ebbc40c0c7528";
      hash = "sha256-YtzaCX8VeFA+NsxrXpNBjN1QbQQgTVLqu8Vc7GrAjzM=";
    };
    nativeBuildInputs = [ pkgs.makeWrapper ];
    # Upstream expects a venv in the app dir, point it at the nix python instead
    postPatch = ''
      substituteInPlace src/main.js \
        --replace-fail "path.join(appRoot, '.venv', 'bin', 'python')" "'${lib.getExe python}'"
    '';
    installPhase = ''
      mkdir -p $out/share/microscope-viewer
      cp -r package.json src bridge assets $out/share/microscope-viewer
      makeWrapper ${lib.getExe pkgs.electron} $out/bin/microscope-viewer \
        --add-flags $out/share/microscope-viewer
    ''
    + lib.optionalString pkgs.stdenv.isLinux ''
      install -Dm644 assets/icon-256.png $out/share/icons/hicolor/256x256/apps/microscope-viewer.png
      cp -r ${desktopItem}/share/applications $out/share
    '';
  };
in
{
  home.packages = [ microscope-viewer ];
}
