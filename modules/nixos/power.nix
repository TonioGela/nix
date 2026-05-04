{ ... }:
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
}
