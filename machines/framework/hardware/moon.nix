{
  fileSystems."/media/Moon" = {
    device = "/dev/disk/by-uuid/2c58c8db-6f8c-4aca-a69e-63780b8e9b89";
    fsType = "ext4";
    options = [
      "x-systemd.automount"
      "noauto"
      "nofail"
      "x-systemd.idle-timeout=60"
      "x-systemd.device-timeout=5s"
      "x-systemd.mount-timeout=5s"
    ];
  };
}
