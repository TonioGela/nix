{ pkgs, ... }:
{
  # iFixit FixHub soldering iron / Smart Station, for the WebSerial console at
  # ifixit.com/fixhub/console. Shipped as a package (not extraRules, which lands in
  # 99-local.rules) so the uaccess tag is seen before systemd's 73-seat-late.rules.
  services.udev.packages = [
    (pkgs.writeTextDir "lib/udev/rules.d/60-ifixit-fixhub.rules" ''
      # FixHub Smart Station (USB VID:PID 346c:1f00)
      ACTION!="remove", SUBSYSTEM=="tty", ATTRS{idVendor}=="346c", ATTRS{idProduct}=="1f00", TAG+="uaccess", ENV{ID_MM_PORT_IGNORE}="1"
      ACTION!="remove", SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="346c", ATTR{idProduct}=="1f00", ENV{ID_MM_DEVICE_IGNORE}="1"

      # FixHub Soldering Iron (USB VID:PID 346c:1f01)
      ACTION!="remove", SUBSYSTEM=="tty", ATTRS{idVendor}=="346c", ATTRS{idProduct}=="1f01", TAG+="uaccess", ENV{ID_MM_PORT_IGNORE}="1"
      ACTION!="remove", SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="346c", ATTR{idProduct}=="1f01", ENV{ID_MM_DEVICE_IGNORE}="1"

      # Not from iFixit: firmware updates talk WebUSB to the raw USB device in DFU
      # mode, which the tty rules above don't cover. Grant any iFixit-vendor device.
      ACTION!="remove", SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="346c", TAG+="uaccess", ENV{ID_MM_DEVICE_IGNORE}="1"
    '')
  ];
}
