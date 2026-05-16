{
  fileSystems."/media/trimui" = {
    device = "//trimui.local/share";
    fsType = "cifs";
    options = [
      "x-systemd.automount"
      "noauto"
      "x-systemd.idle-timeout=60" # Disconnects after 60 seconds of inactivity
      "x-systemd.device-timeout=5s"
      "x-systemd.mount-timeout=5s"

      # Samba options
      "username=root"
      "password=linux"
      "uid=1000"
      "gid=100"
      "dir_mode=0755"
      "file_mode=0755"
    ];
  };
}
