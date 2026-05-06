{
  lib,
  pkgs,
  config,
  ...
}:
let
  skhdExe = lib.getExe pkgs.skhd;
  yabaiExe = lib.getExe pkgs.yabai;
  firefoxCommand = "cmd + shift - return : open '${config.home.homeDirectory}/Applications/Home Manager Apps/Firefox.app'";
in
{
  home.packages = [
    pkgs.skhd
    pkgs.yabai
  ];

  home.activation.yabai = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${yabaiExe} --stop-service
    ${yabaiExe} --uninstall-service
    ${yabaiExe} --install-service
    ${yabaiExe} --start-service
  '';

  home.activation.skhd = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${skhdExe} --stop-service
    ${skhdExe} --uninstall-service
    ${skhdExe} --install-service
    ${skhdExe} --start-service
  '';

  home.file.".config/skhd/skhdrc".text = ''
    # if you're having troubles finding key codes for a key
    # just type skhd --observe in a terminal and type a key.

    # Quickly restart the yabai && skhd launch agents
    alt + cmd - r : ${skhdExe} --restart-service && ${yabaiExe} --restart-service

    cmd - return : /Users/toniogela/.nix-profile/bin/kitty "${config.home.homeDirectory}"
    ${firefoxCommand}
    cmd + shift - s: open "/Users/toniogela/Applications/Home Manager Apps/Slack.app"

    # Toggle window padding
    alt + cmd - p : ${yabaiExe} -m space --toggle padding && ${yabaiExe} -m space --toggle gap
    # Toggle window fullscreen zoom
    alt + cmd - f : ${yabaiExe} -m window --toggle zoom-fullscreen
    # Toggle focus
    alt + cmd - return : ${yabaiExe} -m window --focus next || ${yabaiExe} -m window --focus first
    # Cycle active windows with .
    alt + cmd - 0x2F : ${yabaiExe} -m window --swap next || ${yabaiExe} -m window --swap first
    # Minimize focus window
    alt + cmd - m : ${yabaiExe} -m window $(${yabaiExe} -m query --windows --window | jq .id) --minimize

    # Mirror tree y-axis
    alt + cmd - y : ${yabaiExe} -m space --mirror y-axis
    # Mirror tree x-axis
    alt + cmd - x : ${yabaiExe} -m space --mirror x-axis
    # Rotate the view
    alt + cmd - left:  ${yabaiExe} -m space --rotate 90
    alt + cmd - right: ${yabaiExe} -m space --rotate 270
  '';

  home.file.".config/yabai/yabairc".text = ''
    #!/usr/bin/env sh

    # FLOATING WINDOWS
    ${yabaiExe} -m rule --add app=".*"                         sub-layer=normal
    ${yabaiExe} -m rule --add app="^Stickies$"                 sub-layer=above manage=off
    ${yabaiExe} -m rule --add app="^Disk Utility$"             sub-layer=above manage=off
    ${yabaiExe} -m rule --add app="^ES-DE$"                    sub-layer=above manage=off
    ${yabaiExe} -m rule --add app="^PCSX2.*"                   sub-layer=above manage=off
    ${yabaiExe} -m rule --add app="^Dolphin.*"                 sub-layer=above manage=off
    ${yabaiExe} -m rule --add title="^Extension:.*Bitwarden.*" sub-layer=above manage=off

    # Ignoring tabs
    ${yabaiExe} -m signal --add app='^Finder$' event=window_created action='yabai -m space --layout bsp'
    ${yabaiExe} -m signal --add app='^Finder$' event=window_destroyed action='yabai -m space --layout bsp'

    # New window spawns to the right if vertical split, or bottom if horizontal split
    ${yabaiExe} -m config window_placement second_child

    ${yabaiExe} -m config window_opacity off
    ${yabaiExe} -m config window_opacity_duration 0.00
    ${yabaiExe} -m config active_window_opacity 1.0
    ${yabaiExe} -m config window_border off

    ## some other settings
    ${yabaiExe} -m config auto_balance off
    ${yabaiExe} -m config split_ratio 0.50

    # general space settings
    #${yabaiExe} -m config focused_border_skip_floating  1

    ## Change how yabai looks
    ${yabaiExe} -m config layout bsp
    ${yabaiExe} -m config top_padding 5
    ${yabaiExe} -m config bottom_padding 10
    ${yabaiExe} -m config left_padding 10
    ${yabaiExe} -m config right_padding 10
    ${yabaiExe} -m config window_gap 10

    ${yabaiExe} -m signal --add event=window_destroyed action="yabai -m window --focus last"
    ${yabaiExe} -m rule --apply
  '';
}
