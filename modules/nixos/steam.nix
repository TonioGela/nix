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
    r2modman
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
}
