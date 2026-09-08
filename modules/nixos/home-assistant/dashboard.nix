# Declarative Lovelace dashboard.
#
# services.home-assistant.lovelaceConfig renders an attrset to
# /var/lib/hass/ui-lovelace.yaml and registers it as an *extra* dashboard
# (lovelace.dashboards.nixos-lovelace), so the UI-managed Overview keeps
# working untouched next to it.
#
# This module only knows how to lay cards out. The entity IDs go in the
# machine config, because hon and panasonic_cc derive them from the appliance
# names set in their respective clouds and so differ per install. List the
# real ones under Developer Tools -> States, or with:
#
#   hass-cli --server https://home.toniogela.dev --token <token> entity list
{
  config,
  lib,
  ...
}:
let
  cfg = config.hass.dashboard;

  # attrValues alone would order cards alphabetically by attribute name.
  ordered =
    attrs:
    lib.sort (a: b: if a.order != b.order then a.order < b.order else a.title < b.title) (
      lib.attrValues attrs
    );

  sensorRow = lib.types.listOf (
    lib.types.submodule {
      options = {
        entity = lib.mkOption {
          type = lib.types.str;
          description = "Entity ID of the row.";
        };
        name = lib.mkOption {
          type = lib.types.str;
          description = "Label shown for it.";
        };
      };
    }
  );

  # A thermostat plus the readings that explain what it is doing.
  acSection = unit: {
    type = "grid";
    cards = [
      {
        type = "heading";
        heading = unit.title;
        heading_style = "title";
      }
      {
        type = "thermostat";
        entity = unit.entity;
        features = [
          { type = "climate-hvac-modes"; }
          { type = "climate-fan-modes"; }
        ];
      }
    ]
    ++ lib.optional (unit.sensors != [ ]) {
      type = "entities";
      entities = map (s: { inherit (s) entity name; }) unit.sensors;
    };
  };

  # Appliances report a status string; the countdown is only meaningful while
  # one is actually reachable. It goes in as a *conditional row* rather than a
  # conditional card, so it sits inside the same card as the other readings
  # instead of floating under them as a detached box.
  applianceSection = appliance: {
    type = "grid";
    cards = [
      {
        type = "heading";
        heading = appliance.title;
        heading_style = "title";
      }
      {
        type = "entities";
        entities = [
          {
            entity = appliance.status;
            name = appliance.statusLabel;
          }
        ]
        ++ lib.optional (appliance.remaining != null) {
          type = "conditional";
          conditions = [
            {
              condition = "state";
              entity = appliance.status;
              state_not = "unavailable";
            }
          ];
          row = {
            entity = appliance.remaining;
            name = appliance.remainingLabel;
          };
        }
        ++ map (s: { inherit (s) entity name; }) appliance.sensors;
      }
    ];
  };
in
{
  options.hass.dashboard = {
    climate = lib.mkOption {
      default = { };
      description = ''
        AC units to put on the Climate view, keyed by an arbitrary name. Left
        empty the view is not rendered at all.
      '';
      example = lib.literalExpression ''
        {
          living_room = {
            title = "Living room";
            entity = "climate.living_room";
            sensors = [
              { name = "Inside"; entity = "sensor.living_room_inside_temperature"; }
            ];
          };
        }
      '';
      type = lib.types.attrsOf (
        lib.types.submodule (
          { name, ... }:
          {
            options = {
              title = lib.mkOption {
                type = lib.types.str;
                default = name;
                description = "Heading shown above the thermostat.";
              };
              entity = lib.mkOption {
                type = lib.types.str;
                description = "The climate.* entity of the indoor unit.";
              };
              order = lib.mkOption {
                type = lib.types.int;
                default = 100;
                description = "Sort key; attribute names alone would order the cards alphabetically.";
              };
              sensors = lib.mkOption {
                type = sensorRow;
                default = [ ];
                description = "Rows listed under the thermostat, in order.";
              };
            };
          }
        )
      );
    };

    appliances = lib.mkOption {
      default = { };
      description = ''
        Appliances to put on the Laundry view, keyed by an arbitrary name.
        Left empty the view is not rendered at all.
      '';
      example = lib.literalExpression ''
        {
          washer = {
            title = "Washing machine";
            status = "sensor.washing_machine_machine_status";
            remaining = "sensor.washing_machine_remaining_time";
            sensors = [
              { name = "Program"; entity = "sensor.washing_machine_program"; }
            ];
          };
        }
      '';
      type = lib.types.attrsOf (
        lib.types.submodule (
          { name, ... }:
          {
            options = {
              title = lib.mkOption {
                type = lib.types.str;
                default = name;
                description = "Heading shown above the appliance.";
              };
              status = lib.mkOption {
                type = lib.types.str;
                description = "Entity holding the machine status string.";
              };
              statusLabel = lib.mkOption {
                type = lib.types.str;
                default = "Status";
                description = "Label for the status row.";
              };
              remainingLabel = lib.mkOption {
                type = lib.types.str;
                default = "Time remaining";
                description = "Label for the countdown row.";
              };
              order = lib.mkOption {
                type = lib.types.int;
                default = 100;
                description = "Sort key; attribute names alone would order the cards alphabetically.";
              };
              remaining = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = ''
                  Entity holding the time left. Null drops the countdown card.
                '';
              };
              sensors = lib.mkOption {
                type = sensorRow;
                default = [ ];
                description = "Rows listed under the status, in order.";
              };
            };
          }
        )
      );
    };
  };

  config = lib.mkIf (cfg.climate != { } || cfg.appliances != { }) {
    services.home-assistant.lovelaceConfig.views =
      lib.optional (cfg.climate != { }) {
        title = "Climate";
        path = "climate";
        icon = "mdi:air-conditioner";
        type = "sections";
        max_columns = 2;
        sections = map acSection (ordered cfg.climate);
      }
      ++ lib.optional (cfg.appliances != { }) {
        title = "Laundry";
        path = "laundry";
        icon = "mdi:washing-machine";
        type = "sections";
        max_columns = 2;
        sections = map applianceSection (ordered cfg.appliances);
      };

    # The module would otherwise title this "Overview", which collides with the
    # UI-managed dashboard of the same name in the sidebar. require_admin is the
    # coarse access lever: false lets every logged-in account see it, true hides
    # it from non-admins entirely.
    services.home-assistant.config.lovelace.dashboards.nixos-lovelace = {
      mode = "yaml";
      filename = "ui-lovelace.yaml";
      title = "Home";
      icon = "mdi:home-heart";
      show_in_sidebar = true;
      require_admin = false;
    };
  };
}
