{
  pkgs,
  pkgsUnstable,
  modules,
  ...
}:
{
  imports =
    with modules.nixos;
    [
      niri
      noctalia
      plymouth
      audio
      greetd
      network
      nix-ld
      postgres
      power
      printers
      quiet-boot
      security
      steam
      trimui
      udisks
      virtualisation
    ]
    ++ [
      ./hardware.nix
      ./amd-fix.nix
    ];

  home-manager.users.toniogela.imports = with modules.home-manager; [
    firefox
    git
    retro-gaming
    scala
    vscodium
    zathura
    gpg
    hide-desktop-entries
    kitty
    mpv
    neovim
    nh-npins
    nix-index
    yazi
    zsh
  ];

  boot.kernelPackages = pkgsUnstable.linuxPackages;
  networking.hostName = "toniogela-nixos-fw13";

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  users.users.toniogela.isNormalUser = true;
  users.users.toniogela.extraGroups = [
    "wheel"
    "gamemode"
    "lpadmin"
    "input"
    "kvm"
  ];

  environment.systemPackages = with pkgs; [
    bitwarden-desktop
    qbittorrent
    vesktop
    claude-code
  ];

  home-manager.users.toniogela = {
    git = {
      username = "Antonio Gelameris";
      email = "toniogela89@gmail.com";
      signingKey = "";
    };

    programs.nh = {
      nhFile = "/home/toniogela/.config/nix/configuration.nix";
      nhAttrPath = "framework";
    };

    firefox.additionalExtensions = [
      {
        shortId = "my-online-learning-downloader";
        uuid = "{1b6043a9-46df-4352-adf6-553ce26b9106}";
      }
    ];

    xdg.desktopEntriesToHide = [
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
}
