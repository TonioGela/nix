{
  pkgs,
  pkgsUnstable,
  modules,
  ...
}:
{
  imports = with modules.nixos; [
    ./hardware
    de-channel
    home-assistant
    #    immich
    #    jellyfin
    passwordless-sudoer
    ssh-keys
    tailscale
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgsUnstable.linuxPackages;

  networking.hostName = "eddie";
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  time.timeZone = "Europe/Rome";
  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.extraLocales = [ "it_IT.UTF-8/UTF-8" ];
  passwordlessSudoer = "toniogela";

  environment.systemPackages = [
    pkgs.git
    pkgs.neovim
    pkgsUnstable.nh
    pkgsUnstable.npins
  ];

  services.openssh.enable = true;

  services.caddy = {
    enable = true;
    virtualHosts."hello-world.toniogela.dev".extraConfig = ''
      respond "Hello, world!"
    '';
    virtualHosts."photos.toniogela.dev".extraConfig = ''
      reverse_proxy localhost:2283
    '';
    virtualHosts."netflix.toniogela.dev".extraConfig = ''
      reverse_proxy localhost:8096
    '';
    virtualHosts."home.toniogela.dev".extraConfig = ''
      reverse_proxy localhost:8123
    '';
  };

  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  tailscale.routingFeatures = "server";

  services.resolved.enable = true;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    ipv4 = true;
    ipv6 = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

  systemd.services.home-assistant = {
    after = [ "tailscaled.service" ];
    wants = [ "tailscaled.service" ];
  };

  hass.dashboard = {
    climate.living_room = {
      title = "Condizionatore Salotto";
      order = 1;
      entity = "climate.condizionatore_salotto";
      sensors = [
        {
          name = "Interno";
          entity = "sensor.condizionatore_salotto_inside_temperature";
        }
        {
          name = "Esterno";
          entity = "sensor.condizionatore_salotto_outside_temperature";
        }
      ];
    };

    climate.bedroom = {
      title = "Condizionatore Studio";
      order = 2;
      entity = "climate.condizionatore_studio";
      sensors = [
        {
          name = "Interno";
          entity = "sensor.condizionatore_studio_inside_temperature";
        }
        {
          name = "Esterno";
          entity = "sensor.condizionatore_studio_outside_temperature";
        }
      ];
    };

    appliances.washer = {
      title = "Lavatrice";
      order = 3;
      statusLabel = "Stato";
      remainingLabel = "Tempo rimanente";
      status = "sensor.lavatrice_machine_status";
      remaining = "sensor.lavatrice_time_remaining";
      sensors = [
        {
          name = "Programma";
          entity = "sensor.lavatrice_program";
        }
        {
          name = "Temperatura";
          entity = "sensor.lavatrice_temperature";
        }
        {
          name = "Centrifuga";
          entity = "sensor.lavatrice_spin";
        }
        {
          name = "Blocco porta";
          entity = "binary_sensor.lavatrice_door_lock";
        }
      ];
    };

    appliances.dryer = {
      title = "Asciugatrice";
      order = 4;
      statusLabel = "Stato";
      remainingLabel = "Tempo rimanente";
      status = "sensor.asciugatrice_machine_status";
      remaining = "sensor.asciugatrice_time_remaining";
      sensors = [
        {
          name = "Programma";
          entity = "sensor.asciugatrice_program";
        }
        {
          name = "Porta";
          entity = "binary_sensor.asciugatrice_door_open";
        }
      ];
    };
  };
}
