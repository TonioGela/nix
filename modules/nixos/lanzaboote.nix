{ pkgs, sources, ... }:
{
  imports = [ sources.lanzaboote ];
  environment.systemPackages = [ pkgs.sbctl ];
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };
}
