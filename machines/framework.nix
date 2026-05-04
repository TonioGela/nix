{ sources, modules }:
{
  imports = [
    modules.nixos.hardware
    modules.nixos.plymouth
    modules.nixos.greetd
    modules.nixos.network
    modules.nixos.polkit
    modules.nixos.postgres
    modules.nixos.steam
    modules.nixos.trimui
    modules.nixos.virtualisation
    sources.nix-index-database
    sources.noctalia
  ];

  home-manager.users.toniogela.imports = with modules.home-manager; [
    dotfiles
    firefox
    neovim
    udiskie
    vscodium
    yazi
    zsh
  ];

  environment = {
    variables."NH_FILE" = "/etc/nixos/configuration.nix";
    variables."NH_ATTRP" = "framework";
  };

  networking.hostName = "toniogela-nixos-fw13";
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

  programs.nix-index-database.comma.enable = true;
  programs.zsh.enable = true;
  programs.zoxide.enable = true;
  programs.niri.enable = true;

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

  security.rtkit.enable = true;

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
      kitty
      gh
      ripgrep
      qbittorrent
      zathura
      icdiff
      vesktop
      swaybg
      qemu_full
      pgcli
      wl-clipboard-rs
      scanmem
      scala-cli
      claude-code
    ]
    ++ [
      sources.pkgsUnstable.bitwarden-desktop
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
}
