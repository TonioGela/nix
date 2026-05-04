{ sources, modules }:
{
  imports =
    with modules.nixos;
    [
      hardware
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
      sources.nix-index-database
      sources.noctalia
    ];

  home-manager.users.toniogela.imports = with modules.home-manager; [
    dotfiles
    firefox
    vscodium
    neovim
    zsh
  ];

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
    scala-cli
  ];
}
# TODO merge it with the home-manager config in the other repo and move packages from systemPackages to home-manager packages
