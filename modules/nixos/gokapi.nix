{ pkgs, config, ... }:
let
  cfg = config.gokapi;
  # DynamicUser state lives under /var/lib/private
  stateDir = "/var/lib/private/gokapi";
  image = "/var/lib/gokapi.img";
in
{
  options.gokapi = {
    domain = pkgs.lib.mkOption {
      type = pkgs.lib.types.str;
      description = "Domain caddy serves gokapi on";
    };
    size = pkgs.lib.mkOption {
      type = pkgs.lib.types.str;
      default = "2G";
      description = "Total space for gokapi's state, in truncate(1) units";
    };
  };

  config = {
    services.gokapi.enable = true;
    # Gokapi has no landing page, / and /index redirect here; pointing it at the domain loops
    services.gokapi.settings.RedirectUrl = "https://${cfg.domain}/admin";
    # Base of the generated download links
    services.gokapi.settings.ServerUrl = "https://${cfg.domain}/";
    # ponytail: hardcoded to match the default size, update both together
    services.gokapi.settings.MaxFileSizeMB = 2048;
    services.gokapi.settings.PublicName = "TonioGelaTransfer";
    services.gokapi.settings.IncludeFilename = true;

    # Gokapi has no global quota, so its whole state lives in a fixed-size ext4
    # image created on first start and mounted only when gokapi needs it.
    # ponytail: size only applies at creation, delete the image (and its data) to change it
    systemd.services.gokapi-image = {
      unitConfig.ConditionPathExists = "!${image}";
      serviceConfig.Type = "oneshot";
      path = [
        pkgs.coreutils
        pkgs.e2fsprogs
      ];
      script = ''
        truncate -s ${cfg.size} ${image}.tmp
        mkfs.ext4 -q -m 0 ${image}.tmp
        mv ${image}.tmp ${image}
      '';
    };

    systemd.mounts = [
      {
        what = image;
        where = stateDir;
        type = "ext4";
        options = "loop";
        requires = [ "gokapi-image.service" ];
        after = [ "gokapi-image.service" ];
      }
    ];

    systemd.services.gokapi.unitConfig.RequiresMountsFor = stateDir;
    # The setup wizard's default database path is relative to the cwd, which is / otherwise
    systemd.services.gokapi.serviceConfig.WorkingDirectory = "/var/lib/gokapi";
    # The mount would create it 0755, systemd wants it 0700 for DynamicUser
    systemd.tmpfiles.rules = [ "d /var/lib/private 0700 root root -" ];

    services.caddy.virtualHosts.${cfg.domain}.extraConfig = ''
      redir / /admin
      reverse_proxy localhost:${toString config.services.gokapi.environment.GOKAPI_PORT}
    '';
  };
}
