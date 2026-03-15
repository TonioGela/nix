{ pkgs, ... }:
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
    };
    initLua = ''
      require("full-border"):setup {
        -- Available values: ui.Border.PLAIN, ui.Border.ROUNDED
        type = ui.Border.ROUNDED,
      }
      Status:children_add(function(self)
        local h = self._current.hovered
        if h and h.link_to then
          return " -> " .. tostring(h.link_to)
        else
          return ""
        end
      end, 3300, Status.LEFT)
      Status:children_add(function()
        local h = cx.active.current.hovered
        if not h or ya.target_family() ~= "unix" then
          return ""
        end

        return ui.Line {
          ui.Span(ya.user_name(h.cha.uid) or tostring(h.cha.uid)):fg("magenta"),
          ":",
          ui.Span(ya.group_name(h.cha.gid) or tostring(h.cha.gid)):fg("magenta"),
          " ",
        }
      end, 500, Status.RIGHT)
    '';
    settings = {

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
      ];
    };
  };
}
