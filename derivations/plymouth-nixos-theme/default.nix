{ sources, ... }:

sources.pkgs.stdenv.mkDerivation {
  pname = "nixos-bgrt-2";
  version = "1.0.0";

  src = ./.;

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/plymouth/themes/nixos-bgrt-2
    cp -r * $out/share/plymouth/themes/nixos-bgrt-2/
    substituteInPlace $out/share/plymouth/themes/nixos-bgrt-2/*.plymouth --replace '@IMAGES@' "$out/share/plymouth/themes/nixos-bgrt-2/images"

    runHook postInstall
  '';

  meta = {
    description = "My custom Plymouth theme";
    license = sources.pkgs.lib.licenses.gpl2Only;
    platforms = sources.pkgs.lib.platforms.linux;
  };
}
