{ sources, ... }:
{
  boot = {
    initrd = {
      verbose = false;
      kernelModules = [ "amdgpu" ];
      availableKernelModules = [ "amdgpu" ];
      systemd = {
        enable = true;
        services.plymouth-start = {
          wantedBy = [ "initrd.target" ];
          after = [ "dev-dri-card1.device" ];
          wants = [ "dev-dri-card1.device" ];
        };
      };
      # This udev rule creates a 'card1' device that is used by the plymouth service
      services.udev.rules = ''
        SUBSYSTEM=="drm", KERNEL=="card1", SUBSYSTEMS=="pci", ATTRS{vendor}=="0x1002", TAG+="systemd"
      '';
    };
    plymouth = {
      enable = true;
      theme = "nixos-bgrt";
      themePackages = [
        (import ./plymouth-nixos-theme { inherit sources; })
      ];
    };
  };
}
