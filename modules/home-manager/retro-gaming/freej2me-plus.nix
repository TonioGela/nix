# J2ME core, not in nixpkgs. The .so is patched to run the jar from $out with
# a store JRE, so nothing has to be dropped in retroarch's system dir.
{
  stdenv,
  fetchFromGitHub,
  ant,
  jdk,
  jre,
}:
stdenv.mkDerivation {
  pname = "libretro-freej2me-plus";
  version = "0-unstable-2026-11-16";

  src = fetchFromGitHub {
    owner = "TASEmulators";
    repo = "freej2me-plus";
    rev = "f4e04d7b6d516ab64ed99a2d3582dfeb87d15bce";
    hash = "sha256-V+UN7eRTKLmrgR8Srt3FHlcAGpmglcQin78yxZVPzRs=";
  };

  nativeBuildInputs = [
    ant
    jdk
  ];

  postPatch = ''
    substituteInPlace src/libretro/freej2me_libretro.c \
      --replace-fail '"freej2me_plus-lr.jar"' "\"$out/share/freej2me/freej2me_plus-lr.jar\"" \
      --replace-fail '"%s/%s", systemPath, freej2meapp' '"%s", freej2meapp' \
      --replace-fail 'strdup("java")' 'strdup("${jre}/bin/java")' \
      --replace-fail 'Environ(RETRO_ENVIRONMENT_SET_MESSAGE_EXT, (void*)&messages[RUNTIME_NOT_FOUND_MSG]);' ""
  '';

  buildPhase = ''
    runHook preBuild
    # build.xml targets Java 1.5, which modern javac refuses
    ant -Dsource.version=8 -Dtarget.version=8 jar-libretro
    make -C src/libretro
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm644 build/freej2me_plus-lr.jar -t $out/share/freej2me
    install -Dm755 src/libretro/freej2me_plus_libretro.so -t $out/lib/retroarch/cores
    runHook postInstall
  '';

  passthru.libretroCore = "/lib/retroarch/cores";
}
