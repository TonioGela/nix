{
  config,
  lib,
  ...
}:
let
  cfg = config.services.webdav;
in
{
  options.webdav.directory = lib.mkOption {
    type = lib.types.str;
    description = "Directory served over WebDAV";
    default = "/var/lib/webdav";
  };

  config = {
    sops.secrets.webdav-user = { };
    sops.secrets.webdav-password = { };
    sops.templates."webdav.env" = {
      owner = cfg.user;
      restartUnits = [ "webdav.service" ];
      content = ''
        WEBDAV_USER=${config.sops.placeholder.webdav-user}
        WEBDAV_PASSWORD=${config.sops.placeholder.webdav-password}
      '';
    };

    services.webdav = {
      enable = true;
      environmentFile = config.sops.templates."webdav.env".path;
      settings = {
        # Only ever reached through caddy's reverse proxy, never directly on 8090
        address = "127.0.0.1";
        port = 8090;
        directory = config.webdav.directory;
        permissions = "CRUD";
        behindProxy = true;
        users = [
          {
            username = "{env}WEBDAV_USER";
            password = "{env}WEBDAV_PASSWORD";
          }
        ];
      };
    };

    systemd.tmpfiles.rules = [ "d ${config.webdav.directory} 0750 ${cfg.user} ${cfg.group} -" ];
  };
}
