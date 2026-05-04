{ sources, ... }:
{
  environment.systemPackages = [
    sources.pkgs.pgcli
  ];

  virtualisation.oci-containers.containers = {
    postgres = {
      image = "postgres:17.2";
      ports = [ "5432:5432" ];
      environment = {
        POSTGRES_USER = "toniogela";
        POSTGRES_PASSWORD = "password";
        POSTGRES_DB = "postgres";
      };
      volumes = [
        "/home/toniogela/postgres-volume:/var/lib/postgresql/data"
        "/run/postgresql:/var/run/postgresql"
      ];
    };
  };
}
