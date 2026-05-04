{ sources, ... }:
{
  services.greetd = {
    enable = true;
    useTextGreeter = true;
    settings = {
      switch = false;
      initial_session = {
        command = "niri-session &> /dev/null";
        user = "toniogela";
      };

      default_session = {
        command = "${sources.pkgs.tuigreet}/bin/tuigreet --time --cmd 'niri-session &> /dev/null' --asterisks --remember --theme 'border=white;time=black;title=white;prompt=white;button=black;action=black'";
        user = "toniogela";
      };
    };
  };
}
