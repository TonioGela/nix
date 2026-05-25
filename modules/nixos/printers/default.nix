{ pkgs, ... }:
{

  # User must be in "lp" or "lpadmin" group
  services.printing = {
    enable = true;
    package = pkgs.cups;
    startWhenNeeded = true;
    webInterface = true;
    drivers = with pkgs; [
      cups-filters
      brlaser
    ];
  };

  hardware.printers = {
    ensurePrinters = [
      {
        name = "Brother_DCP-1610W";
        deviceUri = "dnssd://Brother%20DCP-1610W%20series._printer._tcp.local/?uuid=e3248000-80ce-11db-8000-485f9971fd39";
        model = "drv:///brlaser.drv/br1610.ppd";
        ppdOptions = {
          # lpoptions -p Brother_DCP-1610W -l
          PageSize = "A4";
          Resolution = "600dpi";
          InputSlot = "Auto";
          MediaType = "PLAIN";
          brlaserEconomode = "True";
          brlaserDensityAdjus = "103";
        };
      }
    ];
    ensureDefaultPrinter = "Brother_DCP-1610W";
  };

  # User must be in "scanner" group
  hardware.sane.enable = true;
  hardware.sane.extraBackends = [ pkgs.sane-airscan ];

  environment.systemPackages = [
    (pkgs.makeDesktopItem {
      name = "manage-printing";
      desktopName = "Printers";
      exec = "xdg-open http://localhost:631";
      icon = ./printer.svg;
    })
    pkgs.simple-scan
  ];

  # TODO Consider re-enabling this after 26.05
  # hardware.sane.brscan4.enable = true;
  # hardware.sane.brscan4.netDevices = {
  #   Brother_DCP-1610W = {
  #     model = "Brother_DCP-1610W";
  #     # http://BRN485F9971FD39.local/
  #     nodename = "BRN485F9971FD39"; # avahi-browse -art | grep -i brother
  #   };
  # };

  # systemd.tmpfiles.rules = [
  #   "L+ /opt/brother/scanner/brscan4 - - - - ${pkgs.brscan4}/opt/brother/scanner/brscan4"
  # ];
}
