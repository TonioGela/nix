# "Ring a phone": a dropdown of everyone's phone plus a button that rings the
# selected one loudly enough to be heard through Do Not Disturb or a flipped
# silent switch.
#
# A plain notification is not enough for that, and the two platforms need
# opposite amounts of help:
#
#   * Android needs everything spelled out. `channel: alarm_stream_max` is what
#     carries the notification past Do Not Disturb -- the docs are explicit
#     that nothing else overrides DND -- and it is documented to also play the
#     sound as loud as it can. That second half does not hold up here: measured
#     on a Fairphone on Android 15 with companion app 2026.6.5, a notification
#     on that channel is audible under DND but only ever as loud as the
#     *notification* volume. So the phone is set up explicitly before it rings,
#     with command_dnd, command_ringer_mode and command_volume_level.
#   * iOS needs none of that. `critical: 1` on the notification's sound plays
#     "even if Do Not Disturb is enabled or the iPhone is muted", at the
#     `volume` given rather than at the ringer's, so silent mode and Focus are
#     both covered by the payload alone. The commands below are Android
#     features and are skipped for iOS targets; the phone's owner does have to
#     let the companion app send critical alerts.
#
# A notification sound is also short; repeat buys length on either platform.
#
# Two Android caveats worth knowing before trusting any of this:
#
#   * command_dnd needs a permission "the app is unable to prompt or
#     auto-accept", so it has to be granted by hand, and on Android 15 and
#     newer the app may only switch DND *off* again if HA is what switched it
#     on. A DND the owner turned on themselves does not come off this way.
#   * command_ringer_mode does not have that restriction, and setting `normal`
#     on a phone in DND turns DND off as a side effect. On Android 15 that
#     makes the ringer command, not the DND command, the thing that actually
#     clears DND.
{
  config,
  lib,
  ...
}:
let
  cfg = config.hass.ringPhone;

  # attrValues alone would order the dropdown alphabetically by attribute name.
  targets = lib.sort (a: b: if a.order != b.order then a.order < b.order else a.title < b.title) (
    lib.attrValues cfg.targets
  );

  selectEntity = "input_select.ring_phone_target";

  service = target: "notify.${lib.removePrefix "notify." target.service}";

  command = target: name: data: {
    action = service target;
    data = {
      message = "command_${name}";
      inherit data;
    };
  };

  send = target: {
    action = service target;
    data = {
      title = cfg.notificationTitle;
      message = cfg.notificationMessage;
      data =
        if target.platform == "android" then
          {
            channel = "alarm_stream_max";
            priority = "high";
            # Ring now or not at all: a phone that was off should not start
            # ringing by itself an hour later.
            ttl = 0;
          }
        else
          {
            push.sound = {
              name = "default";
              critical = 1;
              volume = 1.0;
            };
          };
    };
  };

  # A trailing delay on the last pass costs nothing: mode is restart, so a
  # second press cuts it short anyway.
  peal =
    target:
    if cfg.repeat.count > 1 then
      [
        {
          repeat = {
            count = cfg.repeat.count;
            sequence = [
              (send target)
              { delay.seconds = cfg.repeat.interval; }
            ];
          };
        }
      ]
    else
      [ (send target) ];

  android = target: target.platform == "android";

  # Volumes are set and left there. The level is deliberately absurd: the
  # companion app caps whatever it is given at the stream's own maximum, which
  # differs per device and per stream, so one number covers every phone.
  prepare =
    target:
    lib.optionals (android target) (
      lib.optional (cfg.dndMode != null) (command target "dnd" { command = cfg.dndMode; })
      ++ lib.optional (cfg.ringerMode != null) (
        command target "ringer_mode" { command = cfg.ringerMode; }
      )
      ++ lib.optionals (cfg.volume.level != null) (
        map (
          stream:
          command target "volume_level" {
            media_stream = stream;
            command = cfg.volume.level;
          }
        ) cfg.volume.streams
      )
    );

  ring = target: prepare target ++ peal target;
in
{
  options.hass.ringPhone = {
    targets = lib.mkOption {
      default = { };
      description = ''
        Phones that can be rung, keyed by an arbitrary name. Left empty
        nothing is rendered and no helper is created.

        Titles end up as the options of the dropdown and are what the script
        matches on, so they have to be unique.
      '';
      example = lib.literalExpression ''
        {
          antonio = {
            title = "Antonio";
            service = "mobile_app_pixel_9";
            platform = "android";
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
                description = "Label shown in the dropdown.";
              };
              service = lib.mkOption {
                type = lib.types.str;
                example = "mobile_app_pixel_9";
                description = ''
                  The phone's notify service. The `notify.` prefix is optional.
                '';
              };
              platform = lib.mkOption {
                type = lib.types.enum [
                  "android"
                  "ios"
                ];
                description = ''
                  Which payload gets past the phone's silent mode, and whether
                  the Android setup commands are sent at all.
                '';
              };
              order = lib.mkOption {
                type = lib.types.int;
                default = 100;
                description = "Sort key; attribute names alone would order the dropdown alphabetically.";
              };
            };
          }
        )
      );
    };

    volume = {
      level = lib.mkOption {
        type = lib.types.nullOr lib.types.ints.unsigned;
        default = null;
        example = 100;
        description = ''
          Turn every stream in `streams` up to this before ringing, which on
          Android is the only thing that governs how loud a notification
          actually is. Null leaves the volumes alone.

          The scale is the device's own and its maximum differs per device and
          per stream, but the companion app caps whatever it is given at that
          maximum, so any comfortably large number means "as loud as this
          phone goes". Nothing is put back afterwards.
        '';
      };

      streams = lib.mkOption {
        type = lib.types.listOf (
          lib.types.enum [
            "alarm_stream"
            "assistant_stream"
            "call_stream"
            "dtmf_stream"
            "music_stream"
            "notification_stream"
            "ring_stream"
            "system_stream"
          ]
        );
        default = [
          "alarm_stream"
          "call_stream"
          "dtmf_stream"
          "music_stream"
          "notification_stream"
          "ring_stream"
          "system_stream"
        ];
        description = ''
          Which streams `level` is applied to, one command each. The default
          is every stream the companion app knows about except
          assistant_stream, which needs Android 17 or newer.

          A notification lands on the notification stream even when
          `channel: alarm_stream_max` has carried it through Do Not Disturb;
          confirm which one is playing by pressing the volume rocker while the
          phone rings, which makes Android show that stream's slider.
        '';
      };
    };

    ringerMode = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "normal"
          "silent"
          "vibrate"
        ]
      );
      default = null;
      example = "normal";
      description = ''
        Take the phone out of vibrate or silent before ringing it. Null leaves
        the ringer alone, and it is never put back. Android targets only.

        Setting `normal` or `vibrate` on a phone that has Do Not Disturb on
        also turns Do Not Disturb off, and unlike `dndMode` this is not
        restricted on Android 15, which makes it the reliable way to clear a
        DND the owner set themselves.
      '';
    };

    dndMode = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "alarms_only"
          "off"
          "priority_only"
          "total_silence"
        ]
      );
      default = null;
      example = "off";
      description = ''
        Put the phone's Do Not Disturb into this state before ringing. Null
        leaves it alone, and it is never put back. Android targets only.

        This needs a permission the companion app cannot prompt for, so it has
        to be granted by hand, and on Android 15 and newer the app may only
        switch DND off again if a Home Assistant command is what switched it
        on -- so against a DND the owner set themselves, expect `ringerMode`
        to be what actually clears it.
      '';
    };

    repeat = {
      count = lib.mkOption {
        type = lib.types.ints.positive;
        default = 1;
        description = "How many times one press rings the phone.";
      };

      interval = lib.mkOption {
        type = lib.types.ints.positive;
        default = 5;
        description = "Seconds between those rings.";
      };
    };

    title = lib.mkOption {
      type = lib.types.str;
      default = "Ring a phone";
      description = "Title of the view and of the card on it.";
    };

    selectLabel = lib.mkOption {
      type = lib.types.str;
      default = "Phone";
      description = "Label of the dropdown row.";
    };

    buttonLabel = lib.mkOption {
      type = lib.types.str;
      default = "Ring";
      description = "Label of the button that sends the notification.";
    };

    notificationTitle = lib.mkOption {
      type = lib.types.str;
      default = "Ring";
      description = "Title of the notification that lands on the phone.";
    };

    notificationMessage = lib.mkOption {
      type = lib.types.str;
      default = "Someone is looking for this phone.";
      description = "Body of the notification that lands on the phone.";
    };
  };

  config = lib.mkIf (cfg.targets != { }) {
    # Two phones sharing a title would give the dropdown two identical options,
    # and the script would always ring whichever one it matched first.
    assertions = [
      {
        assertion = lib.length (lib.unique (map (t: t.title) targets)) == lib.length targets;
        message = "hass.ringPhone.targets: titles have to be unique, they are the options of ${selectEntity}.";
      }
    ];

    services.home-assistant.config = {
      input_select.ring_phone_target = {
        name = cfg.selectLabel;
        icon = "mdi:cellphone";
        options = map (t: t.title) targets;
      };

      # Merges with the empty "script manual" in default.nix; the UI-managed
      # scripts.yaml is untouched by this.
      "script manual".ring_phone = {
        alias = cfg.title;
        icon = "mdi:bell-ring";
        # Tapping twice should ring twice, not be dropped as "already running".
        mode = "restart";
        fields.target = {
          name = "Target";
          description = "Title of the phone to ring. Defaults to the dashboard selection.";
          selector.text = { };
        };
        sequence = [
          { variables.phone = "{{ target | default(states('${selectEntity}'), true) }}"; }
          {
            choose = map (t: {
              conditions = [ "{{ phone == ${builtins.toJSON t.title} }}" ];
              sequence = ring t;
            }) targets;
          }
        ];
      };
    };

    hass.dashboard.extraViews = [
      {
        title = cfg.title;
        path = "ring-phone";
        icon = "mdi:cellphone-sound";
        type = "sections";
        max_columns = 2;
        sections = [
          {
            type = "grid";
            cards = [
              {
                type = "heading";
                heading = cfg.title;
                heading_style = "title";
              }
              {
                type = "entities";
                entities = [
                  {
                    entity = selectEntity;
                    name = cfg.selectLabel;
                  }
                ];
              }
              {
                type = "button";
                name = cfg.buttonLabel;
                icon = "mdi:bell-ring";
                show_state = false;
                tap_action = {
                  action = "perform-action";
                  perform_action = "script.ring_phone";
                };
              }
            ];
          }
        ];
      }
    ];
  };
}
