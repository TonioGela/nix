{
  lib,
  pkgs,
  modulesPath,
  modules,
  ...
}:
{
  imports = with modules.nixos; [
    (modulesPath + "/installer/sd-card/sd-image-aarch64.nix")
    network
    passwordless-sudoer
    sops
    ssh-keys
    tailscale
    wifi
  ];

  sdImage.compressImage = false;
  networking.hostName = "angus";
  hardware.enableRedistributableFirmware = true;
  sops.defaultSopsFile = ./secrets.yml;
  boot.supportedFilesystems.zfs = lib.mkForce false;
  zramSwap.enable = true;
  services.openssh.enable = true;
  services.avahi.publish = {
    enable = true;
    addresses = true;
  };
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
  passwordlessSudoer = "toniogela";
  tailscale.routingFeatures = "client";

  networking.firewall.allowedTCPPorts = [ 80 ];
  systemd.services.hello = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.busybox}/bin/busybox httpd -f -p 80 -h ${pkgs.writeTextDir "index.html" "Hello from Angus\n"}";
      DynamicUser = true;
      AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
    };
  };
}
