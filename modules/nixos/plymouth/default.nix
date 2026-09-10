{ pkgs, ... }:
{

  # Have a look at these
  # https://github.com/helsinki-systems/plymouth-theme-nixos-bgrt/blob/master/nixos-bgrt.plymouth
  # https://github.com/NixOS/nixpkgs/blob/nixos-25.11/pkgs/by-name/ni/nixos-bgrt-plymouth/package.nix#L35
  # https://github.com/adi1090x/plymouth-themes/blob/master/pack_4/spinner_alt/spinner_alt.script

  # Loading amdgpu in the initrd is what reprograms the panel -- the flicker -- right where the logo
  # and the passphrase prompt live. Kept out of stage 1, the whole initrd runs on simpledrm with a
  # single renderer that never changes under the prompt; amdgpu loads in stage 2 instead, so the
  # flicker lands on the splash after unlocking. nixos-hardware's common/gpu/amd turns this on with
  # mkDefault, so it has to be switched off explicitly -- emptying boot.initrd.kernelModules is not
  # enough. Trade-off: the initrd renders at the EFI framebuffer's mode, not the panel's native one.
  hardware.amdgpu.initrd.enable = false;

  # The firmware hands over a GOP framebuffer smaller than the panel, so the initrd splash was
  # drawn at that size and then sat unscaled in the middle of the screen once amdgpu set the
  # native 2880x1920 mode -- the split-second low-res redraw. video=efifb:auto makes the EFI stub
  # pick the highest-resolution mode before ExitBootServices, so simpledrm inherits the native
  # size and the image is identical either side of the modeset. Use video=efifb:2880x1920 to pin
  # one mode, or video=efifb:list to have the stub print what the firmware offers.
  boot.kernelParams = [ "video=efifb:auto" ];

  boot = {
    initrd = {
      verbose = false;
      systemd.enable = true;
    };
    plymouth = {
      enable = true;
      theme = "nixos-bgrt";
      themePackages = [ (import ./plymouth-nixos-theme { inherit pkgs; }) ];

      # plymouthd burns ~700ms compiling an xkb keymap before it even looks for a DRM device, so it
      # starts at sysinit.target (the nixpkgs module already wants it there) and does that work while
      # the rest of the initrd comes up.
      #
      # UseSimpledrm=1 is mandatory now that no real card appears in the initrd: plymouth draws the
      # BGRT splash on the firmware framebuffer straight away. At 0 it would wait out DeviceTimeout
      # (8s) for a card that never arrives and fall back to the text renderer -- that is the systemd
      # text leaking into the boot.
      extraConfig = "UseSimpledrm=1";
    };
  };
}
