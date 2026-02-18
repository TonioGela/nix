let
  sources = import ./npins;
  nixpkgs = sources.nixpkgs;
  pkgs = import nixpkgs { };
  nixos = import (nixpkgs + "/nixos");
  installation-cd-minimal = import (
    nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
  );
  compat = import sources.flake-compat;
  disko = compat { src = sources.disko; };
  line = s: ''echo -e "\e[1;32m${s}\e[0m"'';
  lines = [
    (line "Clone your config then run")
    (line "  disko --mode destroy,format,mount <disko.nix> (aliased to disko-destroy-format-mount)")
    (line "Move the config in /mnt/etc/nixos with")
    (line "  cp -r <cloned-folder>/* /mnt/etc/nixos")
    (line "And then nixos-install -f /mnt/etc/nixos/configuration.nix")
    (line "To set a password for a user")
    (line "  nixos-enter --root /mnt -c 'passwd <user>' (aliased to user-passwd)")
  ];
  command = builtins.concatStringsSep "\n" lines;
  # channel = import (nixpkgs + "/nixos/modules/installer/cd-dvd/channel.nix");
in
(nixos {
  configuration = {
    imports = [
      installation-cd-minimal
      # <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
    ];

    programs.bash.interactiveShellInit = command;

    environment.systemPackages = [
      pkgs.neovim
      disko.outputs.packages.x86_64-linux.disko
      pkgs.git
      (pkgs.writeShellScriptBin "instructions" "${command}")
      (pkgs.writeShellScriptBin "disko-destroy-format-mount" ''disko --mode destroy,format,mount "$@"'')
      (pkgs.writeShellScriptBin "user-passwd" ''nixos-enter --root /mnt -c 'passwd "$@"' '')
    ];
  };
}).config.system.build.isoImage
