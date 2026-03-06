# This is nixos-rebuild switch compatible file
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
    noctalia-shell.outputs.nixosModules.default
  ];

  nixpkgs.pkgs = sources.pkgs;

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
  };

  systemd.services.NetworkManager-wait-online.enable = false;

  boot = {
    loader.timeout = 0;
    consoleLogLevel = 0;
    kernelPackages = sources.pkgs.linuxPackages;
    kernelParams = [
      "quiet"
      "loglevel=0"
      "systemd.show_status=false"
      "rd.systemd.show_status=false"
      "udev.log_level=0"
      "rd.udev.log_level=0"
      "udev.log_priority=0"
      "vt.global_cursor_default=0"
      "amdgpu.dcdebugmask=0x10"
      "nowatchdog"
      "i8042.nopnp"
      "pcie_aspm=off"
      "8250.nr_uarts=0"
      "plymouth.use-simpledrm"
    ];
    initrd = {
      verbose = false;
      systemd.enable = true;
      kernelModules = [ "amdgpu" ];
    };
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        editor = false;
        consoleMode = "5";
        configurationLimit = 10;
      };
    };
    plymouth = {
      enable = true;
      theme = "breeze"; # "breeze" or bgrt
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
    enableAllFirmware = true;
    enableRedistributableFirmware = true;
  };

  security.rtkit.enable = true;

  time.timeZone = "Europe/Rome";

  fonts.packages = [ sources.pkgs.nerd-fonts.sauce-code-pro ];

  i18n = {
    defaultLocale = "en_GB.UTF-8";
    extraLocales = [ "it_IT.UTF-8/UTF-8" ];
  };

  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  users.defaultUserShell = sources.pkgs.zsh;
  users.users.toniogela = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "gamemode"
      "lpadmin"
      "input"
    ];
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  # You should fix the modules to be as shallow as possible and to install packages in global packages (the reason some stuff is installed but not available is this one)
  home-manager.users.toniogela =
    { config, ... }:
    {
      home.packages = [ ];
      home.enableNixpkgsReleaseCheck = true;
      home.file = {
        ".config/niri/config.kdl".source = ./dotfiles/niri.kdl;
        ".config/wallpaper.svg".source = ./dotfiles/wallpaper.svg;
        ".config/kitty/kitty.conf".source = ./dotfiles/kitty.conf;
        "notes.md".source = config.lib.file.mkOutOfStoreSymlink ./dotfiles/notes.md;
        ".config/noctalia/settings.json".source =
          config.lib.file.mkOutOfStoreSymlink ./dotfiles/noctalia-settings.json;
      };

      services.swayidle = {
        enable = true;
        timeouts = [
          {
            timeout = 120;
            command = "${sources.pkgs.lib.getExe noctalia-shell.outputs.packages.x86_64-linux.default} ipc call lockScreen lock";
          }
          {
            timeout = 300;
            command = "${sources.pkgs.lib.getExe noctalia-shell.outputs.packages.x86_64-linux.default} ipc call sessionMenu lockAndSuspend";
          }
        ];
        events = [
          {
            event = "before-sleep";
            command = "${sources.pkgs.lib.getExe noctalia-shell.outputs.packages.x86_64-linux.default} ipc call lockScreen lock";
          }
        ];
      };

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
      comma
      brightnessctl
      playerctl
      framework-tool-tui
      kitty
      yazi
      gh
      ripgrep
      qbittorrent
      xwayland-satellite
      zathura
      icdiff
      vesktop
      (retroarch.withCores (
        cores: with cores; [
          mgba
          play
        ]
      ))
    ]
    ++ [ sources.pkgsUnstable.calibre ];

  services.udisks2 = {
    enable = true;
    mountOnMedia = true;
  };

  services.noctalia-shell.enable = true;
  services.udev.packages = [ sources.pkgs.game-devices-udev-rules ];
  services.udev.extraRules = ''
    KERNEL=="event*", SUBSYSTEM=="input", MODE="0660", GROUP="input"
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
  programs.waybar.enable = false;
  programs.firefox.enable = false;

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
