# Passwords live in ./secrets.env (sops dotenv, `VAR=password`), decrypted at activation
# with the machine's passwordless gpg key. Networks map SSID → variable, null for open ones.
{ config, lib, sources, ... }:
{
  imports = [ sources.sopsNixos ];

  sops.gnupg.home = "/var/lib/sops/gnupg";
  sops.secrets.wifi = {
    sopsFile = ./secrets.env;
    format = "dotenv";
    key = "";
  };

  networking.networkmanager.ensureProfiles = {
    environmentFiles = [ config.sops.secrets.wifi.path ];
    profiles =
      lib.mapAttrs
        (
          ssid: var:
          {
            connection = {
              id = ssid;
              type = "wifi";
            };
            wifi.ssid = ssid;
          }
          // lib.optionalAttrs (var != null) {
            wifi-security = {
              key-mgmt = "wpa-psk";
              psk = "$" + var;
            };
          }
        )
        {
          Galileo = "GALILEO";
          "Le Labo Coworking" = "LE_LABO";
        };
  };
}
