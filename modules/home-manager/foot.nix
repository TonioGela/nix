{
  config,
  lib,
  ...
}:
{
  options = {
    foot.fontSize = lib.mkOption {
      type = lib.types.str;
      default = "10.0";
    };
  };

  config = {

    xdg.desktopEntries.foot = {
      name = "foot";
      noDisplay = true;
    };

    xdg.desktopEntries.foot-server = {
      name = "foot Server";
      noDisplay = true;
    };

    programs.foot = {
      enable = true;
      server.enable = true;
      settings = {
        main = {
          font = "SauceCodePro Nerd Font Mono:size=${config.foot.fontSize}";
          pad = "4x4";
        };

        cursor.style = "beam";
        mouse.hide-when-typing = "yes";

        # Nord Theme from https://github.com/nordtheme/foot
        colors-dark = {
          foreground = "d8dee9";
          background = "2e3440";
          selection-foreground = "000000";
          selection-background = "fffacd";
          urls = "0087bd";
          # black
          regular0 = "3b4252";
          bright0 = "4c566a";
          # red
          regular1 = "bf616a";
          bright1 = "bf616a";
          # green
          regular2 = "a3be8c";
          bright2 = "a3be8c";
          # yellow
          regular3 = "ebcb8b";
          bright3 = "ebcb8b";
          # blue
          regular4 = "81a1c1";
          bright4 = "81a1c1";
          # magenta
          regular5 = "b48ead";
          bright5 = "b48ead";
          # cyan
          regular6 = "88c0d0";
          bright6 = "8fbcbb";
          # white
          regular7 = "e5e9f0";
          bright7 = "eceff4";
        };
      };
    };
  };
}
