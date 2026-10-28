{
  programs.niri.enable = true;
  programs.ydotool.enable = true;
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
          (pkgs.writeShellScriptBin "autoclick" ''
            pid=$XDG_RUNTIME_DIR/autoclick.pid
            if [ -f "$pid" ] && kill "$(cat "$pid")" 2>/dev/null; then rm "$pid"; exit; fi
            echo $$ > "$pid"
            while :; do ${pkgs.ydotool}/bin/ydotool click 0xC0; sleep 0.05; done
          '')
        ];
      }
    )
  ];
}
