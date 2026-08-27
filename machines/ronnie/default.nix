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
    printers
    de-channel
    gpu-screen-recorder
    greetd
    lanzaboote
    minidlna
    network
    nix-ld
    postgres
    power
    quiet-boot
    security
    steam
    tailscale
    trimui
    udisks
    virtualisation
    waydroid
  ];

  home-manager.users.toniogela.imports = with modules.home-manager; [
    calibre
    firefox
    git
    retro-gaming
    scala
    sops
    vscodium
    zathura
    claude
    foot
    gpg
    hide-desktop-entries
    kitty
    minesweep
    mpv
    neovim
    nix-tools
    pass
    wormhole
    yazi
    zsh
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  networking.hostName = "ronnie";

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
    "dialout"
  ];

  services.udev.extraRules = ''
    # Epilogue GB Operator
    SUBSYSTEM=="usb", ATTR{idVendor}=="16d0", ATTR{idProduct}=="123d", MODE="0666"
    KERNEL=="ttyACM*", SUBSYSTEMS=="usb", ATTRS{idVendor}=="16d0", MODE="0666"
  '';

  home-manager.users.toniogela = {
    home.packages = [
      pkgs.qbittorrent
      pkgsUnstable.vesktop
      pkgs.mkvtoolnix
      pkgs.mediainfo
      pkgs.ffmpeg-full
    ];

    sops.secrets.desktop-note.path = "/home/toniogela/note.txt";

    programs.nh = {
      nhFile = "/home/toniogela/.config/nix/configuration.nix";
      nhAttrPath = "ronnie";
      deployments = [
        {
          configurationName = "eddie";
          configurationKind = "nixos";
          targetHost = "eddie.shrimp-pogona.ts.net";
          tailscale = true;
        }
        {
          configurationName = "gilderien";
          configurationKind = "nixos";
          targetHost = "gilderien.toniogela.dev";
        }
      ];
    };

    git = {
      username = "Antonio Gelameris";
      email = "toniogela89@gmail.com";
      signingKey = "0x1D9D8B09A88D614A";
    };

    gpg = {
      defaultSigningKeyId = "0x6D2351BB1BF7ACA9";
      trustedKeyId = "0x6D2351BB1BF7ACA9";
      sshKeys = [ "65014B28CA93A00A77A764610942A029901F5E77" ]; # Keygrip of the 0x6D2351BB1BF7ACA9
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
