{
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend-then-hibernate";
    HandleLidSwitchExternalPower = "suspend-then-hibernate";
    HandleLidSwitchDocked = "suspend-then-hibernate";
    HoldoffTimeoutSec = 10;
  };

  services.upower.enable = true;
  systemd.sleep.extraConfig = "HibernateDelaySec=5m";
  services.power-profiles-daemon.enable = true;

  environment.etc."systemd/system-sleep/pre-hibernate-drop-cache" = {
    mode = "0755";
    text = ''
      #!/bin/sh
      if [ "$1" = "pre" ] && [ "$2" = "hibernate" ]; then
        logger -t pre-hibernate-drop-cache "starting: $(free -m | awk '/^Mem:/{printf "%sMB free %sMB cached", $4, $6}')"
        sync
        echo 3 > /proc/sys/vm/drop_caches
        echo 0 > /sys/power/image_size
        logger -t pre-hibernate-drop-cache "done: $(free -m | awk '/^Mem:/{printf "%sMB free %sMB cached", $4, $6}')"
      fi
    '';
  };
}
