{
  services.udisks2 = {
    enable = true;
    mountOnMedia = true;
  };

  home-manager.sharedModules = [
    {
      services.udiskie = {
        enable = true;
        automount = true;
        notify = true;
        tray = "auto";
        settings = {
          program_options = {
            terminal = "kitty -d";
          };
          device_config = [
            {
              device_file = "/dev/sda";
              #id_uuid = "2c58c8db-6f8c-4aca-a69e-63780b8e9b89"; # This is /media/Moon
              ignore = true;
            }
          ];
        };
      };
    }
  ];
}
