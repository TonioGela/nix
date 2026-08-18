{
  pkgs,
  pkgsUnstable,
  config,
  ...
}:
{
  options = {
    tailscale.routingFeatures = pkgs.lib.mkOption {
      type = pkgs.lib.types.enum [
        "client"
        "server"
      ];
      description = "Tailscale routing features, either client or server";
      default = "client";
    };
  };

  config = {
    services.tailscale = {
      enable = true;
      package = pkgsUnstable.tailscale;
      useRoutingFeatures = config.tailscale.routingFeatures;
    };
  };
}
