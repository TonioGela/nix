{ sources, modules }:
{
  imports =
    with modules.nixos;
    [
      plymouth
      audio
      greetd
      network
      postgres
      power
      printers
      quiet-boot
      security
      steam
      trimui
      udisks
      virtualisation
      yazi
      zsh
    ]
    ++ [
      ./hardware.nix
      ./amd-fix.nix
      sources.nix-index-database
      sources.noctalia
    ];

  home-manager.users.toniogela = {
    imports = with modules.home-manager; [
      dotfiles
      firefox
      git
      scala
      vscodium
      neovim
    ];

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
  };

  environment = {
    variables."NH_FILE" = "/etc/nixos/configuration.nix";
    variables."NH_ATTRP" = "framework";
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

  boot.kernelPackages = sources.pkgsUnstable.linuxPackages;

  programs.niri.enable = true;
  services.noctalia-shell.enable = true;
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
    kitty
    mpv
    qbittorrent
    vesktop

    # CLI Utilities
    claude-code
    fd
    fzf
    gh
    icdiff
    ripgrep
  ];
}
# TODO merge it with the home-manager config in the other repo and move packages from systemPackages to home-manager packages
# TODO Postgres is not running?
