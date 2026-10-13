{ pkgs, ... }:
{
  security.rtkit.enable = true;
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # https://github.com/NixOS/nixos-hardware/issues/1603
  services.pipewire.wireplumber.extraConfig.no-ucm = {
    "monitor.alsa.properties" = {
      "alsa.use-ucm" = false;
    };
  };

  # Defaults come from priority.session only, never from ~/.local/state/wireplumber.
  # Picking a device in the UI still works until the next restart.
  services.pipewire.wireplumber.extraConfig.declarative-defaults = {
    "wireplumber.profiles".main."hooks.default-nodes.state" = "disabled";
    "monitor.alsa.rules" = [
      {
        # raw internal mic yields to "Microphone (tuned)"
        matches = [ { "node.name" = "alsa_input.pci-0000_c1_00.6.analog-stereo"; } ];
        actions.update-props."priority.session" = 1000;
      }
      {
        # hidden raw speaker yields to "Framework Speakers" (nixos-hardware pins it at 1009)
        matches = [ { "node.name" = "alsa_output.pci-0000_c1_00.6.analog-stereo"; } ];
        actions.update-props."priority.session" = 1000;
      }
    ];
  };

  # Speaker tuning from nixos-hardware; raw name overridden because UCM is off
  hardware.framework.laptop13.audioEnhancement = {
    enable = true;
    rawDeviceName = "alsa_output.pci-0000_c1_00.6.analog-stereo";
    # echo-cancel must reach the raw speaker's monitor; hidden nodes can't be linked from pipewire-side modules
    hideRawDevice = false;
  };

  # WebRTC echo cancellation: stops the mic picking up the speakers.
  # monitor.mode taps a sink monitor as reference, so no extra sink to route through.
  services.pipewire.extraConfig.pipewire."60-echo-cancel" = {
    "context.modules" = [
      {
        name = "libpipewire-module-echo-cancel";
        args = {
          "library.name" = "aec/libspa-aec-webrtc";
          "monitor.mode" = true;
          # call apps already run their own noise suppression; doing it twice sounds boxy
          "aec.args"."webrtc.noise_suppression" = false;
          # reference = raw speaker monitor, i.e. after the speaker tuning: the bass boost and
          # compressor are non-linear, so referencing the pre-tuning signal leaves echo behind
          "sink.props" = {
            "node.name" = "echo-cancel-sink";
            "target.object" = "alsa_output.pci-0000_c1_00.6.analog-stereo";
          };
          # pin to the raw mic: following the default source would capture "Microphone (tuned)", a loop
          "capture.props" = {
            "node.name" = "echo-cancel-capture";
            "target.object" = "alsa_input.pci-0000_c1_00.6.analog-stereo";
          };
          "source.props" = {
            "node.name" = "echo-cancel-source";
            "node.description" = "Microphone (echo cancelled)";
            "priority.session" = 1500;
          };
        };
      }
    ];
  };

  # EQ after echo cancel: the internal mic is boomy around 125-250 Hz and quiet.
  # Tuned from recordings; tweak Gain/Freq values to taste.
  services.pipewire.extraConfig.pipewire."61-mic-eq" = {
    "context.modules" = [
      {
        name = "libpipewire-module-filter-chain";
        args = {
          "node.description" = "Microphone (tuned)";
          "media.name" = "Microphone (tuned)";
          "filter.graph" = {
            nodes = [
              {
                type = "builtin";
                name = "hp";
                label = "bq_highpass";
                control = {
                  Freq = 120.0;
                  Q = 0.707;
                };
              }
              {
                type = "builtin";
                name = "mud";
                label = "bq_peaking";
                control = {
                  Freq = 180.0;
                  Q = 1.0;
                  Gain = -8.0;
                };
              }
              {
                type = "builtin";
                name = "presence";
                label = "bq_peaking";
                control = {
                  Freq = 3000.0;
                  Q = 1.0;
                  Gain = 3.0;
                };
              }
              {
                type = "builtin";
                name = "gain";
                label = "linear";
                control = {
                  Mult = 1.0;
                };
              } # level is set on the raw mic instead (100%); gain here amplified a -48 dB signal
            ];
            links = [
              {
                output = "hp:Out";
                input = "mud:In";
              }
              {
                output = "mud:Out";
                input = "presence:In";
              }
              {
                output = "presence:Out";
                input = "gain:In";
              }
            ];
          };
          "audio.position" = [
            "FL"
            "FR"
          ];
          "capture.props" = {
            "node.name" = "mic-eq-capture";
            "node.passive" = true;
            "target.object" = "echo-cancel-source";
          };
          "playback.props" = {
            "node.name" = "mic-eq-source";
            "media.class" = "Audio/Source";
            "priority.session" = 2009; # takes over the raw internal mic's slot: BT (~2010) and USB (2100) still win
          };
        };
      }
    ];
  };

  # Pin the two hidden-gain levels on every wireplumber start, so they never depend on ~/.local/state:
  # raw speaker at 100% (volume is controlled on "Framework Speakers"), internal mic at 35% (it has +50 dB hw gain; higher clips).
  systemd.user.services.audio-levels = {
    description = "Set fixed internal mic and raw speaker levels";
    after = [ "wireplumber.service" ];
    partOf = [ "wireplumber.service" ];
    wantedBy = [ "wireplumber.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "audio-levels" ''
        PATH=${pkgs.lib.makeBinPath [ pkgs.pipewire pkgs.wireplumber pkgs.jq pkgs.coreutils ]}
        set_vol() {
          for _ in $(seq 30); do # nodes appear a moment after wireplumber starts
            id=$(pw-dump | jq -r --arg n "$1" '.[] | select(.info.props."node.name"? == $n) | .id')
            [ -n "$id" ] && { wpctl set-volume "$id" "$2"; return; }
            sleep 1
          done
          echo "$1 not found" >&2
        }
        set_vol alsa_output.pci-0000_c1_00.6.analog-stereo 1.0
        set_vol alsa_input.pci-0000_c1_00.6.analog-stereo 0.35
      '';
    };
  };
}
