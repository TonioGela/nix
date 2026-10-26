{
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend-then-hibernate";
    HandleLidSwitchExternalPower = "suspend-then-hibernate";
    HandleLidSwitchDocked = "suspend-then-hibernate";
    HoldoffTimeoutSec = 10;
  };

  services.upower.enable = true;
  systemd.sleep.settings.Sleep.HibernateDelaySec = "5m";
  services.power-profiles-daemon.enable = true;

  # Framework 13 AMD (Ryzen AI 300 / RDNA3.5 iGPU) intermittently fails to resume
  # from hibernation: the kernel's *asynchronous* device-restore path races and the
  # GPU never comes back, e.g.
  #   amdgpu: ring mes_kiq_3.1.0 test failed (-110)
  #   amdgpu: resume of IP block <gfx_v11_0> failed -110
  #   PM: failed to restore async: error -110
  # leaving a black screen / reset and a lost session. Forcing device suspend/resume
  # to run serially (disabling async PM) avoids the race. A/B-tested workaround; root
  # cause is platform firmware (AGESA/PMFW), no upstream fix yet. Trade-off: hibernate
  # entry/exit is slightly slower.
  # https://community.frame.work/t/hibernate-resume-failures-on-framework-13-amd-ryzen-ai-300-krackan-a-b-tested-workaround-pm-async-0/83040
  systemd.tmpfiles.rules = [ "w /sys/power/pm_async - - - - 0" ];

  # Turn the fingerprint/power-button LED off together with the keyboard backlight
  # (fn+space). The EC handles fn+space on its own and has no setting to link the two,
  # so mirror it from sysfs: brightness 0 switches the LED off, the chromeos-auto
  # trigger hands it back to the EC.
  # ponytail: 1s polling (kbd_backlight has no brightness_hw_changed), ~1s lag after fn+space
  systemd.services.fp-led-follow-kbd = {
    wantedBy = [ "multi-user.target" ];
    script = ''
      kbd=/sys/class/leds/chromeos::kbd_backlight/brightness
      led=/sys/class/leds/chromeos:white:power
      prev=
      while sleep 1; do
        read -r b < $kbd
        if [ "$b" -eq 0 ]; then state=off; else state=on; fi
        [ "$state" = "$prev" ] && continue
        if [ "$state" = off ]; then echo 0 > $led/brightness; else echo chromeos-auto > $led/trigger; fi
        prev=$state
      done
    '';
  };

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
