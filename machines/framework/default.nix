{ sources, modules }:
{
  imports = [
    modules.nixos.noctalia
    modules.nixos.plymouth
    modules.nixos.audio
    modules.nixos.greetd
    modules.nixos.network
    modules.nixos.postgres
    modules.nixos.power
    modules.nixos.printers
    modules.nixos.quiet-boot
    modules.nixos.security
    modules.nixos.steam
    modules.nixos.trimui
    modules.nixos.udisks
    modules.nixos.virtualisation
    sources.nix-index-database
    ./hardware.nix
    ./amd-fix.nix
  ];

  home-manager.users.toniogela.imports = [
    modules.home-manager.firefox
    modules.home-manager.git
    modules.home-manager.niri
    modules.home-manager.retro-gaming
    modules.home-manager.scala
    modules.home-manager.vscodium
    modules.home-manager.zathura
    modules.home-manager.hide-desktop-entries
    modules.home-manager.kitty
    modules.home-manager.neovim
    modules.home-manager.yazi
    modules.home-manager.zsh
  ];

  home-manager.users.toniogela = {
    git.username = "Antonio Gelameris";
    git.email = "toniogela89@gmail.com";
    git.signingKey = "";

    firefox.additionalExtensions = [
      {
        shortId = "my-online-learning-downloader";
        uuid = "{1b6043a9-46df-4352-adf6-553ce26b9106}";
      }
    ];
    # https://tsawyer87.github.io/posts/gpg-agent_on_nixos/
    programs.gpg.enable = true;
    services.gpg-agent = {
      enable = true;
      enableZshIntegration = true;
      pinentry.package = sources.pkgs.pinentry-tty;
    };

    desktopEntriesToHide = [
      {
        filename = "cups";
        name = "Manage Printing";
      }
      {
        filename = "mpv";
        name = "mpv Media Player";
      }
      {
        filename = "nixos-manual";
        name = "NixOS Manual";
      }
      {
        filename = "nvim";
        name = "Neovim wrapper";
      }
    ];
  };

  environment = {
    variables.NIXD_PATH = sources.pkgs.lib.getExe sources.pkgs.nixd;
    variables.NH_FILE = "/home/toniogela/.config/nix/configuration.nix";
    variables.NH_ATTRP = "framework";
  };

  networking.hostName = "toniogela-nixos-fw13";

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

  programs.zsh.enable = true;
  users.defaultUserShell = sources.pkgs.zsh;

  boot.kernelPackages = sources.pkgsUnstable.linuxPackages;

  programs.niri.enable = true;
  programs.nix-index-database.comma.enable = true;

  programs.nix-ld = {
    enable = true;
    libraries = with sources.pkgs; [ zlib ];
  };

  environment.systemPackages = with sources.pkgs; [
    nixd
    nixfmt

    # TODO Reference them in the niri config
    brightnessctl
    playerctl
    swaybg
    wl-clipboard-rs

    # GUI programs
    bitwarden-desktop
    mpv
    qbittorrent
    vesktop

    # CLI Utilities
    claude-code
  ];
}
