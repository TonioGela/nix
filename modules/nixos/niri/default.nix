{
  programs.niri.enable = true;
  home-manager.sharedModules = [
    (
      { pkgs, ... }:
      {
        home.file.".config/niri/config.kdl".source = ./niri.kdl;
        home.packages = [
          pkgs.playerctl
          pkgs.wl-clipboard-rs
          pkgs.wl-mirror
          pkgs.jq
        ];
      }
    )
  ];
}
