{ pkgs, ... }:
{
  # ESP8266/ESP32 dev boards reach the host through a USB-serial bridge
  # (CP210x, CH34x, FTDI...). Stock NixOS rules already hand /dev/ttyUSB* to the
  # dialout group, so membership in it is the only hard requirement; these rules
  # add the per-VID/PID handling PlatformIO ships for the boards that need it.
  services.udev.packages = [ pkgs.platformio-core.udev ];
}
