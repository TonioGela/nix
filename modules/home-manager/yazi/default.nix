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

  home.packages = [
    pkgsUnstable.mdfried
  ]
  ++ lib.optionals pkgs.stdenv.isLinux [
    pkgs.glib # gio, needed by the gvfs plugin
    pkgs.ripdrag
    pkgs.loupe # TODO Remove the loupe binding on darwin
  ];

  programs.yazi = {
    package = pkgsUnstable.yazi;
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "y";
    flavors.nord = ./nord;
    theme.flavor = {
      dark = "nord";
      light = "nord";
    };
    plugins = {
      mount = pkgsUnstable.yaziPlugins.mount;
      full-border = pkgsUnstable.yaziPlugins.full-border;
      smart-enter = pkgsUnstable.yaziPlugins.smart-enter;
      chmod = pkgsUnstable.yaziPlugins.chmod;
      compress = pkgsUnstable.yaziPlugins.compress;
      # Deprecated upstream, supports yazi <= 26.9.1: drop it if it breaks
      simple-tag = pkgs.fetchFromGitHub {
        owner = "boydaihungst";
        repo = "simple-tag.yazi";
        rev = "7728d5c506feadc8cb5b7ef699845af7fe92457d";
        hash = "sha256-h3aN1+Ekl+Tg0KCM3hbqMPgSHSYD6RAAcPJUJ0j6UJg=";
      };
    }
    // lib.optionalAttrs pkgs.stdenv.isLinux {
      gvfs = pkgsUnstable.yaziPlugins.gvfs;
    };
    initLua = ''
      require("simple-tag"):setup {
        colors = { w = "green" },
        icons = { w = "✓" },
      }
      ${lib.optionalString pkgs.stdenv.isLinux ''require("gvfs"):setup {}''}
      -- Available values: ui.Border.PLAIN, ui.Border.ROUNDED
      -- require("full-border"):setup { type = ui.Border.ROUNDED }
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
      plugin.prepend_fetchers = [
        {
          id = "simple-tag";
          url = "*";
          run = "simple-tag";
          group = "simple-tag";
        }
        {
          id = "simple-tag";
          url = "*/";
          run = "simple-tag";
          group = "simple-tag";
        }
      ];
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
        {
          url = "*.{xlsx,xls}";
          use = "spreadsheet";
        }
        {
          url = "*.md";
          use = "markdown";
        }
      ];

      opener = {
        image = [
          {
            run = "loupe %s";
            desc = "Loupe image viewer";
            orphan = true;
            for = "linux";
          }
          {
            run = "open -a Preview -F %s";
            desc = "Preview";
            orphan = true;
            for = "macos";
          }
        ];

        play = [
          {
            run = "mpv %s";
            desc = "Mpv Video Player";
            orphan = true;
          }
        ];

        pdf = [
          {
            run = "zathura %s";
            desc = "Zathura PDF viewer";
            orphan = true;
          }
        ];

        html = [
          {
            run = "firefox %s";
            desc = "Firefox Web Browser";
            orphan = true;
          }
        ];

        spreadsheet = [
          {
            run = "gnumeric %s";
            desc = "Gnumeric";
            orphan = true;
          }
        ];

        markdown = [
          {
            run = "mdfried %s";
            desc = "mdfried markdown viewer";
            block = true;
          }
        ];
      };
    };

    keymap = {
      mgr.prepend_keymap = [
        {
          run = "shell 'ripdrag %s -x -a 2>/dev/null &' --confirm";
          on = [ "<C-n>" ];
          desc = "Drag the file";
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
        {
          on = [
            "c"
            "a"
            "a"
          ];
          run = "plugin compress";
          desc = "Archive selected files";
        }
        {
          on = [
            "c"
            "a"
            "p"
          ];
          run = "plugin compress -p";
          desc = "Archive selected files (password)";
        }
        {
          on = [
            "c"
            "a"
            "h"
          ];
          run = "plugin compress -ph";
          desc = "Archive selected files (password+header)";
        }
        {
          on = [
            "c"
            "a"
            "l"
          ];
          run = "plugin compress -l";
          desc = "Archive selected files (compression level)";
        }
        {
          on = [
            "c"
            "a"
            "u"
          ];
          run = "plugin compress -phl";
          desc = "Archive selected files (password+header+level)";
        }
        {
          on = [ "b" ];
          run = "plugin simple-tag -- toggle-tag --key=w";
          desc = "Toggle watched tag";
        }
        {
          on = [ "B" ];
          run = "plugin simple-tag -- filter --key=w --mode=nor";
          desc = "Show only unwatched";
        }
      ]
      ++ lib.optionals pkgs.stdenv.isLinux [
        {
          on = [
            "g"
            "m"
          ];
          run = "plugin gvfs -- select-then-mount --jump";
          desc = "Mount a gvfs device (phone via MTP) and jump to it";
        }
        {
          on = [
            "g"
            "u"
          ];
          run = "plugin gvfs -- select-then-unmount --eject";
          desc = "Unmount a gvfs device";
        }
      ];
    };
  };
}
