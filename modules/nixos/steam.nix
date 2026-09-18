{ pkgs, ... }:
{
  # gamemoderun gamescope -w 1440 -h 960 -W 2880 -H 1920 -F fsr --adaptive-sync -f --mangoapp --force-grab-cursor -- %command%

  hardware.xpadneo.enable = true;
  hardware.steam-hardware.enable = true;
  programs.steam.enable = true;
  programs.gamescope.enable = true;
  programs.gamemode = {
    enable = true;
    enableRenice = true;
    settings = {
      general = {
        renice = 10;
      };
    };
  };

  environment.systemPackages = with pkgs; [
    xwayland-satellite
    mangohud
    scanmem
  ];

  home-manager.sharedModules = [
    {
      home.file.".config/MangoHud/MangoHud.conf".text = ''
        gpu_name
        vulkan_driver
        gpu_stats
        cpu_stats
        fps
        frametime
        gpu_list=0,1
      '';
    }
  ];

  # TODO Test if these are still necessary
  services.udev.packages = [ pkgs.game-devices-udev-rules ];
  services.udev.extraRules = ''
    KERNEL=="event*", SUBSYSTEM=="input", MODE="0660", GROUP="input"
    # Allow Dolphin emulator to access the Bluetooth adapter directly for Passthrough
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="0a12", ATTRS{idProduct}=="0001", RUN+="/bin/sh -c 'echo $kernel > /sys/bus/usb/drivers/btusb/unbind'"
  '';
}
