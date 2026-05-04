{ sources, ... }:
{
  environment.systemPackages = with sources.pkgs; [ qemu_full ];

  virtualisation.vmVariant = {
    environment.variables.SDL_VIDEODRIVER = "wayland";
    boot.kernelParams = [ "video=1920x1080" ];
    users.users.toniogela.password = "1234";
    virtualisation.useEFIBoot = true;
    virtualisation.diskSize = 30000;
    virtualisation.memorySize = 8192;
    virtualisation.cores = 8;
    virtualisation.qemu.options = [
      "-enable-kvm"
      "-device virtio-vga-gl"
      "-display sdl,gl=on"
    ];
    disko.devices.disk.main.device = sources.pkgs.lib.mkForce "/dev/vda";
    disko.devices.disk.main.content.partitions.swap.size = sources.pkgs.lib.mkForce "1G";
    disko.devices.disk.main.content.partitions.swap.content.resumeDevice =
      sources.pkgs.lib.mkForce false;
  };
}
