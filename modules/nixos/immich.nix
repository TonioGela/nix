{ pkgs, ... }:
{
  services.immich = {
    enable = true;
    mediaLocation = "/mnt/photos";
    port = 2283;
    openFirewall = false;

    machine-learning.enable = false;

    # Intel Quick Sync (HD Graphics 500 / Apollo Lake) hardware transcoding
    accelerationDevices = [ "/dev/dri/renderD128" ];
  };

  hardware.graphics = {
    enable = true;
    extraPackages = [ pkgs.intel-media-driver ];
  };
}
