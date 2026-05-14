{
  pkgs,
  lib,
  pkgsUnstable,
  ...
}:
{
  xdg.desktopEntries.yazi = lib.mkIf pkgs.stdenv.isLinux {
    name = "yazi";
    noDisplay = true;
  };

  programs.yazi = {
    package = pkgsUnstable.yazi;
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "y";
    plugins = {
      mount = pkgs.yaziPlugins.mount;
      full-border = pkgs.yaziPlugins.full-border;
      smart-enter = pkgs.yaziPlugins.smart-enter;
      chmod = pkgs.yaziPlugins.chmod;
    };
    initLua = ''
      -- Available values: ui.Border.PLAIN, ui.Border.ROUNDED
      require("full-border"):setup { type = ui.Border.ROUNDED }
      -- Hide StatusBar and Header
      local old_layout = Tab.layout
      Status.redraw = function() return {} end
      Header.redraw = function() return {} end
      Tab.layout = function(self, ...)
        self._area = ui.Rect { x = self._area.x, y = self._area.y - 1, w = self._area.w, h = self._area.h + 2 }
        return old_layout(self, ...)
      end
    '';
    settings = {
      mgr.linemode = "size";
      open.prepend_rules = [
        {
          mime = "image/*";
          use = "image";
        }
        {
          mime = "application/pdf";
          use = "pdf";
        }
        {
          mime = "video/*";
          use = "play";
        }
        {
          mime = "text/html";
          use = "html";
        }
      ];

      # opener.image = [
      #   {
      #     run = "loupe \"$@\"";
      #     desc = "Loupe image viewer";
      #     orphan = true;
      #     for = "unix";
      #   }
      # ];

      opener.play = [
        {
          run = "mpv \"$@\"";
          desc = "Mpv Video Player";
          orphan = true;
        }
      ];

      opener.pdf = [
        {
          run = "zathura \"$@\"";
          desc = "Zathura PDF viewer";
          orphan = true;
        }
      ];

      opener.html = [
        {
          run = "firefox \"$@\"";
          desc = "Firefox Web Browser";
          orphan = true;
        }
      ];
    };

    keymap = {
      mgr.prepend_keymap = [
        {
          run = "shell 'ripdrag \"$@\" -x -a 2>/dev/null &' --confirm";
          on = [ "<C-n>" ];
        }
        {
          run = "plugin chmod";
          on = [
            "c"
            "m"
          ];
          desc = "Chmod the file";
        }
        {
          run = ''shell -- ya emit cd "$(git rev-parse --show-toplevel)"'';
          on = [
            "g"
            "r"
          ];
          desc = "cd to the git root";
        }
        {
          run = "plugin smart-enter";
          on = [ "<Enter>" ];
        }
        {
          run = "plugin fzf";
          on = [ "Z" ];
        }
        {
          run = "plugin zoxide";
          on = [ "z" ];
        }
        {
          run = "plugin mount";
          on = [ "M" ];
        }
      ];
    };
  };
}
