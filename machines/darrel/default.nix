{
  modules,
  pkgs,
  ...
}:
let
  derivations = import ./derivations.nix { inherit pkgs; };
in
{
  imports = with modules.home-manager; [
    firefox
    git
    hypervolt
    scala
    vscodium
    zathura
    darwin
    gpg
    kitty
    neovim
    nix-tools
    pass
    yabai-skhd
    yazi
    zsh
  ];

  home = {
    username = "toniogela";
    homeDirectory = "/Users/toniogela";
  };

  vscodium.profileFile = "home-manager";

  programs.nh = {
    nhFile = "/Users/toniogela/.config/home-manager/configuration.nix";
    nhAttrPath = "darrel";
  };

  home.file.".hushlogin".text = "";

  git = {
    username = "Antonio Gelameris";
    email = "antonio.gelameris@hypervolt.co.uk";
    signingKey = "25901F702B062B05";
    maintainedRepos = [
      "/Users/toniogela/work/athena"
      "/Users/toniogela/work/hypervolt-backend"
    ];
  };

  gpg.sshKeys = [
    # "65014B28CA93A00A77A764610942A029901F5E77" # Keygrip of the 0x6D2351BB1BF7ACA9
  ];

  kitty = {
    fontSize = "14.0";
    extraConfig = ''
      map cmd+c                 copy_to_clipboard
      map cmd+v                 paste_from_clipboard
      map cmd+w                 close_os_window
      macos_quit_when_last_window_closed yes
    '';
  };

  darwin.masAppIds = [
    "1352778147" # Bitwarden
    # "1503136033" # Service Station can't be find for some reason
  ];

  zsh = {
    extraEnv = "eval `/usr/libexec/path_helper -s`";
    extraAliases.flushdns = "sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder";
  };

  home.packages = [
    pkgs.appcleaner
    pkgs.claude-code
    pkgs.defaultbrowser
    pkgs.nerd-fonts.sauce-code-pro
    pkgs.wireshark
    derivations.keeping-you-awake
    derivations.qlmarkdown
    derivations.source-code-syntax-highlight
    derivations.ice-bar # TODO Replace with https://github.com/stonerl/Thaw
  ];

}
