{ sources, ... }:
{
  programs.nix-ld = {
    enable = true;
    libraries = with sources.pkgs; [ zlib ];
  };
}
