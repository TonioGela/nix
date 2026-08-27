{
  modulesPath,
  sources,
  modules,
  ...
}:
{
  imports = with modules.nixos; [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    sources.disko
    ./disko.nix
    passwordless-sudoer
    ssh-keys
    tailscale
  ];

  boot.loader.grub = {
    # no need to set devices, disko adds every disk with an EF02 partition already
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  zramSwap.enable = true;

  networking.hostName = "gilderien";
  networking.useDHCP = true;

  services.openssh.enable = true;
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  services.nginx = {
    enable = true;
    streamConfig = ''
      resolver 100.100.100.100 valid=10s;

      map $ssl_preread_server_name $backend {
        hello-world.toniogela.dev  eddie.shrimp-pogona.ts.net:443;
        default                    "";
      }

      server {
        listen 443;
        listen [::]:443;
        proxy_pass $backend;
        ssl_preread on;
      }
    '';
  };

  passwordlessSudoer = "toniogela";

  tailscale.routingFeatures = "client";
}
