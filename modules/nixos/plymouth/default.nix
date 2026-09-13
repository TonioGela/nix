{ pkgs, ... }:
{

  # Have a look at these
  # https://github.com/helsinki-systems/plymouth-theme-nixos-bgrt/blob/master/nixos-bgrt.plymouth
  # https://github.com/NixOS/nixpkgs/blob/nixos-25.11/pkgs/by-name/ni/nixos-bgrt-plymouth/package.nix#L35
  # https://github.com/adi1090x/plymouth-themes/blob/master/pack_4/spinner_alt/spinner_alt.script

  boot = {
    initrd = {
      verbose = false;
      kernelModules = [ "amdgpu" ];
      availableKernelModules = [ "amdgpu" ];
      systemd.enable = true;
    };
    plymouth = {
      enable = true;
      theme = "nixos-bgrt";
      themePackages = [ (import ./plymouth-nixos-theme { inherit pkgs; }) ];

      # plymouth-start deliberately has no ordering on /dev/dri/card1: plymouthd spends ~700ms
      # compiling an xkb keymap before it even looks for a DRM device, so waiting for the card paid
      # that cost *after* amdgpu's modeset had already blanked the panel -- the firmware logo went
      # away and came back ~800ms later. Started at sysinit.target (where the nixpkgs module already
      # wants it) it does that work while amdgpu is still loading, and paints ~110ms after the card
      # appears.
      #
      # UseSimpledrm=0 is what replaces the old udev-rule-plus-ordering: plymouth ignores the
      # firmware framebuffer and waits for the real card (up to DeviceTimeout, 8s; amdgpu arrives at
      # ~2.5s) instead of drawing on simpledrm and handing over later. That handover is what used to
      # leak systemd text, and it also leaves the passphrase prompt unresponsive until it completes.
      extraConfig = "UseSimpledrm=0";
    };
  };
}
