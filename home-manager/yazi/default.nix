{ pkgs, ... }:
{
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "y";
    plugins = {
      mount = pkgs.yaziPlugins.mount;
    };
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
        # {
        #   run = "shell 'ripdrag \"$@\" -x -a 2>/dev/null &' --confirm";
        #   on = [ "<C-n>" ];
        # }
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
