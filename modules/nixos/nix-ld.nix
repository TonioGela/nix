{ pkgs, ... }:
{
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      zlib
      # horizon-launcher
      libxkbcommon
      libxcb
      vulkan-loader
      wayland
      libglvnd
      alsa-lib
      libx11
      libxcursor
      libxi
      libxrandr
    ];
  };
}
