{ pkgs, ... }:
let
  what-size-plugin = pkgs.fetchFromGitHub {
    owner = "pirafrank";
    repo = "what-size.yazi";
    rev = "main";
    hash = "sha256-7q/45TopqbojNRvYDmP9+hgSGPmiyLHBcV051qpOB2Y=";
  };
in
{
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "y";
    plugins = {
      mount = pkgs.yaziPlugins.mount;
      full-border = pkgs.yaziPlugins.full-border;
      smart-enter = pkgs.yaziPlugins.smart-enter;
      chmod = pkgs.yaziPlugins.chmod;
      what-size = what-size-plugin;
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

      # opener.image = [
      #   {
      #     run = "loupe \"$@\"";
      #     desc = "Loupe image viewer";
      #     orphan = true;
      #     for = "unix";
      #   }
      # ];

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
        {
          run = "plugin what-size";
          on = [
            "."
            "s"
          ];
          desc = "Calc size of selection or cwd";
        }
      ];
    };
  };
}
