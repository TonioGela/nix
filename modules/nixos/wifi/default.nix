# One profile per entry under `wifi:` in the machine's secrets.yml (`<ssid>: <password>`),
# see ../sops.nix. sops only encrypts the values, so the SSIDs are read straight from it.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  # Import from derivation: yj has to be built while evaluating. A `/` in an SSID would
  # clash with how sops-nix names nested keys.
  ssids = lib.importJSON (
    pkgs.runCommand "wifi-ssids.json" { }
      "${lib.getExe pkgs.yj} -yj < ${config.sops.defaultSopsFile} | ${lib.getExe pkgs.jq} '.wifi // {} | keys' > $out"
  );

  # envsubst needs plain variable names, SSIDs can contain anything
  var = ssid: "WIFI_" + builtins.hashString "sha256" ssid;
in
{
  sops.secrets = lib.genAttrs (map (ssid: "wifi/${ssid}") ssids) (_: { });
  sops.templates."wifi.env" = {
    restartUnits = [ "NetworkManager-ensure-profiles.service" ];
    content = lib.concatMapStrings (
      ssid: "${var ssid}=${config.sops.placeholder."wifi/${ssid}"}\n"
    ) ssids;
  };

  networking.networkmanager.ensureProfiles = {
    environmentFiles = [ config.sops.templates."wifi.env".path ];
    profiles = lib.genAttrs ssids (ssid: {
      connection = {
        id = ssid;
        type = "wifi";
      };
      wifi.ssid = ssid;
      wifi-security = {
        key-mgmt = "wpa-psk";
        psk = "$" + var ssid;
      };
    });
  };
}
