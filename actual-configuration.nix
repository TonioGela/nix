let
  pins = import ./npins;
  sources = {
    pkgs = import pins.nixpkgs { config.allowUnfree = true; };
    pkgsUnstable = import pins.nixpkgs-unstable { config.allowUnfree = true; };
    homeManager = import (pins.home-manager + "/nixos");
    fw13-hardware = import (pins.nixos-hardware + "/framework/13-inch/amd-ai-300-series");
    diskoModule = pins.disko + "/module.nix";
    compat = import pins.flake-compat;
    noctalia = pins.noctalia-shell;
    nix-index-database = pins.nix-index-database + "/nixos-module.nix";
  };

  modules = import ./modules { inherit sources; };

  homeManager = import ./home-manager {
    username = "toniogela";
    inherit sources;
  };

  noctalia-shell = sources.compat { src = sources.noctalia; };
in
{
  imports = modules ++ [
    homeManager
    (import sources.nix-index-database)
    noctalia-shell.outputs.nixosModules.default
  ];

  services.resolved.enable = true;

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

  nixpkgs.pkgs = sources.pkgs;

  programs.nix-index-database.comma.enable = true;

  nix = {
    channel.enable = false;
    settings.experimental-features = [ "nix-command" ];
    nixPath = [
      "nixpkgs=/etc/nixos/nixpkgs"
      "nixos-config=/etc/nixos/configuration.nix"
    ];
  };

  environment = {
    etc."nixos/nixpkgs".source = builtins.storePath sources.pkgs.path;
    variables."NH_FILE" = "/etc/nixos/configuration.nix";
    variables."NH_ATTRP" = "framework";
  };

  systemd.services.NetworkManager-wait-online.enable = false;

  boot = {
    consoleLogLevel = 0;
    kernelModules = [ "uinput" ];
    kernelPackages = sources.pkgsUnstable.linuxPackages;
    kernelParams = [
      "quiet"
      "loglevel=0"
      "systemd.show_status=false"
      "rd.systemd.show_status=false"
      "udev.log_level=0"
      "rd.udev.log_level=0"
      "udev.log_priority=0"
      "vt.global_cursor_default=0"
      "nowatchdog"
      "i8042.nopnp"
      "pcie_aspm=off"
      "8250.nr_uarts=0"
    ];
    loader = {
      timeout = 0;
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        editor = false;
        consoleMode = "5";
        configurationLimit = 10;
      };
    };
  };

  networking = {
    networkmanager.enable = true;
    hostName = "toniogela-nixos-fw13"; # Define your hostname.
  };

  hardware = {
    bluetooth.enable = true;
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    steam-hardware.enable = true;
    enableAllFirmware = true;
    enableRedistributableFirmware = true;
  };

  security.rtkit.enable = true;
  security.polkit.enable = true;

  time.timeZone = "Europe/Rome";

  fonts.packages = [ sources.pkgs.nerd-fonts.sauce-code-pro ];

  i18n = {
    defaultLocale = "en_GB.UTF-8";
    extraLocales = [ "it_IT.UTF-8/UTF-8" ];
  };

  users.defaultUserShell = sources.pkgs.zsh;
  users.users.toniogela = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "gamemode"
      "lpadmin"
      "input"
      "kvm"
    ];
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  # You should fix the modules to be as shallow as possible and to install packages in global packages (the reason some stuff is installed but not available is this one)
  home-manager.users.toniogela = {
    home.enableNixpkgsReleaseCheck = true;
    programs.home-manager.enable = true;
    home.stateVersion = "25.11";
  };

  environment.systemPackages =
    with sources.pkgs;
    [
      git
      bat
      eza
      nh
      nixd
      nixfmt
      nixfmt-tree
      npins
      neovim
      mpv
      fd
      ripdrag
      brightnessctl
      playerctl
      framework-tool-tui
      kitty
      gh
      ripgrep
      qbittorrent
      xwayland-satellite
      zathura
      icdiff
      vesktop
      swaybg
      mangohud
      qemu_full
      lutris
      pgcli
      wl-clipboard-rs
      scanmem
      scala-cli
      bitwarden-desktop
      protonup-qt
      (retroarch.withCores (
        cores: with cores; [
          mgba
          play
        ]
      ))
    ]
    ++ [
      sources.pkgsUnstable.nix-fast-build
    ];

  programs.nix-ld = {
    enable = true;
    libraries = with sources.pkgs; [ zlib ];
  };

  services.udisks2 = {
    enable = true;
    mountOnMedia = true;
  };

  services.gvfs.enable = true;

  services.noctalia-shell.enable = true;
  services.udev.packages = [ sources.pkgs.game-devices-udev-rules ];
  services.udev.extraRules = ''
    KERNEL=="event*", SUBSYSTEM=="input", MODE="0660", GROUP="input"
    # Allow Dolphin emulator to access the Bluetooth adapter directly for Passthrough
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="0a12", ATTRS{idProduct}=="0001", RUN+="/bin/sh -c 'echo $kernel > /sys/bus/usb/drivers/btusb/unbind'"
  '';

  services.fwupd.enable = true;
  services.fprintd.enable = true;
  services.upower.enable = true;

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend-then-hibernate";
    HandleLidSwitchExternalPower = "suspend-then-hibernate";
    HandleLidSwitchDocked = "suspend-then-hibernate";
    HoldoffTimeoutSec = 10;
  };

  systemd.sleep.extraConfig = "HibernateDelaySec=5m";

  services.power-profiles-daemon.enable = true;

  services.greetd = {
    enable = true;
    useTextGreeter = true;
    settings = {
      switch = false;
      initial_session = {
        command = "niri-session &> /dev/null";
        user = "toniogela";
      };

      default_session = {
        command = "${sources.pkgs.tuigreet}/bin/tuigreet --time --cmd 'niri-session &> /dev/null' --asterisks --remember --theme 'border=white;time=black;title=white;prompt=white;button=black;action=black'";
        user = "toniogela";
      };
    };
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  services.printing = {
    enable = true;
    drivers = with sources.pkgs; [
      cups-filters
      cups-browsed
      brlaser
    ];
  };

  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # https://github.com/NixOS/nixos-hardware/issues/1603
  services.pipewire.wireplumber.extraConfig.no-ucm = {
    "monitor.alsa.properties" = {
      "alsa.use-ucm" = false;
    };
  };

  programs.zsh.enable = true;
  programs.zoxide.enable = true;

  programs.niri.enable = true;

  hardware.xpadneo.enable = true;

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

  system.copySystemConfiguration = true;

  system.stateVersion = "25.11";
}
