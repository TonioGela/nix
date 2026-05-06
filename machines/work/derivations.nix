{ sources }:
let
  fetchMacAppFromGhReleases =
    {
      author,
      pname,
      version,
      assetName,
      sha256,
      description,
      platform,
    }:
    sources.pkgs.stdenv.mkDerivation {
      inherit pname version;
      src = sources.pkgs.fetchzip {
        url = "https://github.com/${author}/${pname}/releases/download/${version}/${assetName}.zip";
        inherit sha256;
        stripRoot = false;
      };

      installPhase = ''
        runHook preInstall
        mkdir -p $out/Applications
        cp -r * $out/Applications
        rm -rf $out/Applications/__MACOSX || true
        runHook postInstall
      '';

      dontStrip = true;

      meta = {
        inherit description;
        platforms = [ platform ];
      };
    };
in
{
  ice-bar = fetchMacAppFromGhReleases {
    author = "jordanbaird";
    pname = "Ice";
    version = "0.11.13-dev.2";
    assetName = "Ice";
    sha256 = "sha256-B/uTyCnWlLkXZgwFX9HTJhy6aOyWN8aPOxPa93He4uc=";
    description = "Powerful menu bar manager for macOS";
    platform = "aarch64-darwin";
  };
  keeping-you-awake = fetchMacAppFromGhReleases rec {
    author = "newmarcel";
    pname = "KeepingYouAwake";
    version = "1.6.8";
    assetName = "KeepingYouAwake-${version}";
    sha256 = "sha256-npJHX7GrAWHswiCzq7cRDDJudW5duyFEW0W131K1ISc=";
    description = "Caffeine like mac app";
    platform = "aarch64-darwin";
  };
  qlmarkdown = fetchMacAppFromGhReleases {
    author = "sbarex";
    pname = "QLMarkdown";
    version = "1.0.23";
    assetName = "QLMarkdown";
    sha256 = "sha256-3cIdr5KBsjSjnSoKMV699J5R/b3idrjvqX/k2Ao5CT8=";
    description = "Quick look plugin for markdown rendering";
    platform = "aarch64-darwin";
  };
  source-code-syntax-highlight = {
    author = "sbarex";
    pname = "SourceCodeSyntaxHighlight";
    version = "2.1.26";
    assetName = "Syntax.Highlight";
    sha256 = "sha256-iAikrmKlY6AuJYVH4P/KwTPFOGFGPysAsWBK7TNVJoM=";
    description = "Quick look plugin for code highlight";
    platform = "aarch64-darwin";
  };

}
