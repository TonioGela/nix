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
