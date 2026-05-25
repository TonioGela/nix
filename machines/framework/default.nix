{
  pkgs,
  pkgsUnstable,
  modules,
  ...
}:
{
  imports = with modules.nixos; [
    ./hardware
    audio
    niri
    noctalia
    plymouth
    de-channel
    greetd
    network
    nix-ld
    postgres
    power
    printers
    quiet-boot
    security
    steam
    tailscale
    trimui
    udisks
    virtualisation
    yubikey
  ];

  home-manager.users.toniogela.imports = with modules.home-manager; [
    calibre
    firefox
    git
    hypervolt
    retro-gaming
    scala
    vscodium
    zathura
    claude
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

  fonts.packages = [ pkgs.nerd-fonts.sauce-code-pro ];
  time.timeZone = "Europe/Rome";
  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.extraLocales = [ "it_IT.UTF-8/UTF-8" ];

  users.users.toniogela.isNormalUser = true;
  users.users.toniogela.extraGroups = [
    "wheel"
    "gamemode"
    "lpadmin"
    "scanner"
    "input"
    "kvm"
  ];

  home-manager.users.toniogela = {
    home.packages = [
      pkgs.bitwarden-desktop
      pkgs.qbittorrent
      pkgs.vesktop
      pkgs.nix-tree
      pkgs.nix-diff
      pkgsUnstable.vulnix
      (pkgs.symlinkJoin {
        name = "wormhole";
        paths = [ pkgs.wormhole-rs ];
        postBuild = "ln -s $out/bin/wormhole-rs $out/bin/wormhole";
      })
    ];

    programs.nh = {
      nhFile = "/home/toniogela/.config/nix/configuration.nix";
      nhAttrPath = "framework";
    };

    git = {
      username = "Antonio Gelameris";
      email = "toniogela89@gmail.com";
      signingKey = "";
    };

    vscodium.profileFile = "nixos";

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
      {
        filename = "org.gnome.Loupe";
        name = "Image viewer";
      }
    ];
  };
}
