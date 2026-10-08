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
  };

  # WebRTC echo cancellation: stops the mic picking up the speakers.
  # monitor.mode uses the default sink's monitor as reference, so no extra sink to route through.
  services.pipewire.extraConfig.pipewire."60-echo-cancel" = {
    "context.modules" = [
      {
        name = "libpipewire-module-echo-cancel";
        args = {
          "library.name" = "aec/libspa-aec-webrtc";
          "monitor.mode" = true;
          # call apps already run their own noise suppression; doing it twice sounds boxy
          "aec.args"."webrtc.noise_suppression" = false;
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
                  Mult = 4.0;
                };
              } # +12 dB
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
}
