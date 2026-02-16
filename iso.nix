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
  # channel = import (nixpkgs + "/nixos/modules/installer/cd-dvd/channel.nix");
in
(nixos {
  configuration = {
    imports = [
      installation-cd-minimal
      # <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
    ];

    programs.bash.interactiveShellInit = ''
      echo "\e[1;32mClone your config then run[0m"
      echo "\e[1;32m  `disko --mode destroy,format,mount <disko.nix>\e[0m"
      echo "\e[1;32mMove the config in /mnt/etc/nixos with \e[0m"
      echo "\e[1;32m  `sudo cp -r <cloned-folder>/* /etc/nixos`\e[0m"
      echo "\e[1;32mAnd then `nixos-install`"
    '';

    environment.systemPackages = [
      pkgs.neovim
      disko.outputs.packages.x86_64-linux.disko
      pkgs.git
    ];
  };
}).config.system.build.isoImage
