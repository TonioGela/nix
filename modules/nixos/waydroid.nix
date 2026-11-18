{ pkgs, ... }:
{
  virtualisation.waydroid.enable = true;
  virtualisation.waydroid.package = pkgs.waydroid.override { withNftables = true; };
  environment.systemPackages = [ pkgs.waydroid-helper ];
}
