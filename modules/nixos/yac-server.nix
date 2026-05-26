{
  virtualisation.oci-containers.containers.YACReaderLibraryServer = {
    image = "yacreader/yacreaderlibraryserver:latest";
    ports = [ "9999:8080" ];
    environment = {
      PUID = "99";
      PGID = "100";
      TZ = "Europe/Rome";
    };
    volumes = [
      "/tmp/config:/config"
      "/tmp/comics:/comics"
    ];
  };
}
