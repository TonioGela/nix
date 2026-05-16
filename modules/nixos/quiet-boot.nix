{
  boot = {
    consoleLogLevel = 0;
    kernelParams = [
      "quiet"
      "systemd.show_status=false"
      "rd.systemd.show_status=false"
      "udev.log_level=0"
      "rd.udev.log_level=0"
      "udev.log_priority=0"
      "vt.global_cursor_default=0"
      "nowatchdog"
      "8250.nr_uarts=0"
    ];
    loader = {
      timeout = 0;
      systemd-boot = {
        enable = true;
        editor = false;
        consoleMode = "5";
        configurationLimit = 10;
      };
    };
  };
}
