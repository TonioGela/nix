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

  home-manager.sharedModules = [
    {
      services.easyeffects = {
        enable = false;
        preset = "framework-mic";
        extraPresets = {
          framework-mic = builtins.fromJSON (builtins.readFile ./framework-mic.json);
        };
      };
    }
  ];
}
