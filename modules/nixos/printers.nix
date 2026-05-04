{ sources, ... }:
{
  services.printing = {
    enable = true;
    drivers = with sources.pkgs; [
      cups-filters
      cups-browsed
      brlaser
    ];
  };
}
