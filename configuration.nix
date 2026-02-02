let
  sources = import ./npins;
  pkgs = import sources.nixpkgs {
    config.allowUnfree = true;
  };
  pkgsUnstable = import sources.nixpkgs-unstable {
    config.allowUnfree = true;
  };
  nixos = import (sources.nixpkgs + "/nixos");
  fw13-hardware = import (sources.nixos-hardware + "/framework/13-inch/amd-ai-300-series");
  homeManager = import (sources.home-manager + "/nixos");
  diskoModule = sources.disko + "/module.nix";
in
nixos {
  configuration = {
    imports = [
      fw13-hardware
      ./hardware-configuration.nix
      homeManager
      diskoModule
    ];

    nixpkgs.config.allowUnfree = true; # Apparently the bt firmware is not free

    nix = {
      channel.enable = false;
      settings.experimental-features = [ "nix-command" ];
      nixPath = [
        "nixpkgs=/etc/nixos/nixpkgs"
        "nixos-config=/etc/nixos/configuration.nix"
      ];
    };

    environment = {
      etc."nixos/nixpkgs".source = builtins.storePath pkgs.path;
      variables."NH_FILE" = "/etc/nixos/configuration.nix";
    };

    boot = {
      loader.timeout = 0;
      consoleLogLevel = 0;
      kernelPackages = pkgs.linuxPackages_latest;
      kernelParams = [
        "quiet"
        "splash"
        "nowatchdog"
        "loglevel=3"
        "systemd.show_status=false"
        "rd.systemd.show_status=false"
        "udev.log_level=3"
        "rd.udev.log_level=3"
        "udev.log_priority=3"
        "vt.global_cursor_default=0"
      ];
      initrd = {
        verbose = false;
        systemd.enable = true;
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
        theme = "breeze"; # "breeze"
      };
    };

    networking = {
      networkmanager.enable = true;
      hostName = "toniogela-nixos-fw13"; # Define your hostname.
    };

    hardware.bluetooth.enable = true;
    hardware.graphics.enable = true;
    hardware.graphics.enable32Bit = true;
    hardware.enableAllFirmware = true;

    security.rtkit.enable = true;

    time.timeZone = "Europe/Rome";

    fonts.packages = [ pkgs.nerd-fonts.sauce-code-pro ];

    i18n = {
      defaultLocale = "en_GB.UTF-8";
      extraLocales = [ "it_IT.UTF-8/UTF-8" ];
    };

    # console = {
    #   font = "Lat2-Terminus16";
    #   keyMap = "us";
    #   useXkbConfig = true; # use xkb.options in tty.
    # };

    users.defaultUserShell = pkgs.zsh;
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
        imports = [
          ./firefox
          ./zsh
          ./neovim
          ./vscodium
        ];
        _module.args = { inherit pkgsUnstable; };
        home.packages = [ ];
        home.enableNixpkgsReleaseCheck = true;
        home.file = {
          ".config/niri/config.kdl".source = ./dotfiles/niri.kdl;
          ".config/wallpaper.svg".source = ./dotfiles/wallpaper.svg;
          ".config/kitty/kitty.conf".source = ./dotfiles/kitty.conf;
          "notes.md".source = config.lib.file.mkOutOfStoreSymlink ./dotfiles/notes.md;
        };
        programs.home-manager.enable = true;
        home.stateVersion = "25.11";
      };

    environment.systemPackages = with pkgs; [
      git
      bat
      eza
      nh
      swaybg
      nixd
      nixfmt
      nixfmt-tree
      npins
      neovim
      mpv
      comma
      bluetui
      brightnessctl
      playerctl
      framework-tool-tui
      kitty
      pavucontrol
      fuzzel
      yazi
      gh
      ripgrep
      qbittorrent
      xwayland-satellite
      (retroarch.withCores (
        cores: with cores; [
          mgba
          play
        ]
      ))
    ];

    services.udev.packages = [ pkgs.game-devices-udev-rules ];
    services.udev.extraRules = ''
      KERNEL=="event*", SUBSYSTEM=="input", MODE="0660", GROUP="input"
    '';

    services.fwupd.enable = true;
    services.fprintd.enable = true;

    services.logind.settings.Login = {
      HandleLidSwitch = "suspend";
      HandleLidSwitchExternalPower = "suspend";
      HandleLidSwitchDocked = "ignore";
      HoldoffTimeoutSec = 10;
    };

    services.power-profiles-daemon.enable = false;
    services.tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      };
    };

    services.greetd = {
      enable = true;
      useTextGreeter = true;
      settings = {
        switch = false;
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd 'niri-session &> /dev/null' --asterisks --remember --theme 'border=red;time=green;title=green;prompt=green;button=black;action=black'";
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
      drivers = with pkgs; [
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

    # programs.mtr.enable = true;
    # programs.gnupg.agent = {
    #   enable = true;
    #   enableSSHSupport = true;
    # };

    system.copySystemConfiguration = true;

    system.stateVersion = "25.11";
  };
}
