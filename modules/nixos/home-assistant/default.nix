{ pkgs, ... }:
{
  services.home-assistant = {
    enable = true;

    # Only ever reached through caddy's reverse proxy or tailscale, never
    # directly on 8123 from the outside
    openFirewall = false;

    extraComponents = [
      # Required to complete the onboarding
      "default_config"
      "met"
      "esphome"

      # Companion app, so phones can get "washing machine done" notifications
      "mobile_app"
    ];

    customComponents = [
      # Haier washing machine + Candy dryer both speak the hOn cloud API
      (import ./hon.nix { inherit pkgs; })
      # Panasonic ACs, via Comfort Cloud
      (import ./panasonic-cc.nix { inherit pkgs; })
    ];

    config = {
      # zeroconf/ssdp discovery, mobile_app, history, logbook, energy
      default_config = { };

      homeassistant = {
        unit_system = "metric";
        temperature_unit = "C";
        time_zone = "Europe/Rome";
        country = "IT";
        currency = "EUR";
      };

      http = {
        server_port = 8123;
        use_x_forwarded_for = true;
        trusted_proxies = [
          "127.0.0.1"
          "::1"
        ];

        # home.toniogela.dev is public, so ban IPs that keep guessing.
        # X-Forwarded-For is trusted above, so bans hit the real client.
        ip_ban_enabled = true;
        login_attempts_threshold = 5;
      };

      # configuration.yaml is a read-only symlink into /etc, so the UI editors
      # need somewhere writable to put what they create. The "<domain> <name>"
      # keys are split back to the bare domain by home-assistant, which is how
      # both a declarative and a UI-managed list can coexist.
      "automation manual" = [ ];
      "automation ui" = "!include automations.yaml";
      "scene manual" = [ ];
      "scene ui" = "!include scenes.yaml";
      "script manual" = { };
      "script ui" = "!include scripts.yaml";
    };
  };

  # !include fails at startup if the file isn't there yet, and home-assistant
  # only creates them the first time you save from the UI.
  systemd.tmpfiles.rules = [
    "f /var/lib/hass/automations.yaml 0644 hass hass - []"
    "f /var/lib/hass/scenes.yaml 0644 hass hass - []"
    "f /var/lib/hass/scripts.yaml 0644 hass hass - {}"
  ];
}
