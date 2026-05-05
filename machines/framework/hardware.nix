{
  sources,
  ...
}:
rec {
  imports = [
    sources.fw13-hardware
    sources.disko
    ./disko.nix
  ];

  nixpkgs.hostPlatform = sources.pkgs.lib.mkDefault "x86_64-linux";
  environment.systemPackages = [ sources.pkgs.framework-tool-tui ];
  services.fwupd.enable = true;

  boot = {
    loader.efi.canTouchEfiVariables = true;
    extraModulePackages = [ ];
    kernelModules = [ "kvm-amd" ];
    initrd = {
      kernelModules = [ ];
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "thunderbolt"
        "usb_storage"
        "sd_mod"
      ];
    };
  };

  hardware = {
    bluetooth.enable = true;
    enableAllFirmware = true;
    enableRedistributableFirmware = true;
    cpu.amd.updateMicrocode = sources.pkgs.lib.mkDefault hardware.enableRedistributableFirmware;
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };
}
