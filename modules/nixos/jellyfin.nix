{ pkgs, ... }:
{
  services.jellyfin = {
    enable = true;
    # Only ever reached through caddy's reverse proxy, never directly on 8096
    openFirewall = false;

    # Intel Quick Sync (HD Graphics 500 / Apollo Lake) hardware transcoding
    hardwareAcceleration = {
      enable = true;
      type = "vaapi";
      device = "/dev/dri/renderD128";
    };
  };

  # The jellyfin module only adds a DeviceAllow for the render node, but the
  # node itself stays root:render 0660, so the service user needs the group.
  users.users.jellyfin.extraGroups = [
    "render"
    "video"
  ];

  hardware.graphics = {
    enable = true;
    extraPackages = [ pkgs.intel-media-driver ];
  };
}
