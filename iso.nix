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
  command = ''
    echo "\e[1;32mClone your config then run[0m"
    echo "\e[1;32m  \`disko --mode destroy,format,mount <disko.nix>\`\e[0m"
    echo "\e[1;32mMove the config in /mnt/etc/nixos with \e[0m"
    echo "\e[1;32m  \`sudo cp -r <cloned-folder>/* /etc/nixos\`\e[0m"
    echo "\e[1;32mAnd then \`nixos-install\`\e[0m"
    echo "\e[1;32mTo set a password for a user\e[0m"
    echo "\e[1;32m \`nixos-enter --root /mnt -c 'passwd <user>'\`\e[0m"
  '';
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
    ];
  };
}).config.system.build.isoImage
