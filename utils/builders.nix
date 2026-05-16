{ sources, modules }:
{
  nixos =
    system: config:
    sources.nixosBuilder {
      inherit system;
      specialArgs = { inherit sources modules; };
      configuration = {
        imports = [
          (import config)
          sources.homeManager
        ];

        config = {
          _module.args.pkgsUnstable = sources.pkgsUnstable;

          nix.optimise.automatic = true;
          nix.optimise.persistent = true;
          nix.optimise.dates = "weekly";

          # Can't set it to true if you don't have nixos-config in nix path
          system.copySystemConfiguration = false;
          system.stateVersion = "25.11";

          time.timeZone = "Europe/Rome";
          i18n.defaultLocale = "en_GB.UTF-8";
          i18n.extraLocales = [ "it_IT.UTF-8/UTF-8" ];

          nixpkgs.pkgs = sources.pkgs;
          nix.package = sources.pkgsUnstable.nix;
          nix.channel.enable = false;
          nix.settings.experimental-features = [ "nix-command" ];
          nix.nixPath = [ "nixpkgs=${builtins.storePath sources.pkgs.path}" ];

          home-manager = {
            useGlobalPkgs = true; # use system's nixpkgs
            useUserPackages = true; # installs user packages via users.users.<name>.packages
            extraSpecialArgs = { inherit sources; };
            sharedModules = [
              {
                _module.args.pkgsUnstable = sources.pkgsUnstable;

                programs.home-manager.enable = true;
                home.enableNixpkgsReleaseCheck = true;
                home.stateVersion = "25.11";
              }
            ];
          };
        };
      };
    };

  home-manager =
    config:
    sources.homeManagerBuilder {
      pkgs = sources.pkgs;
      extraSpecialArgs = { inherit sources; };
      configuration = {
        imports = [ (import config { inherit sources modules; }) ]; # TODO Do the same on mac
        config = {
          _module.args.pkgsUnstable = sources.pkgsUnstable;

          programs.home-manager.enable = true;
          home.enableNixpkgsReleaseCheck = true;
          home.stateVersion = "25.11";

          nixpkgs.pkgs = sources.pkgs;
          nix.package = sources.pkgsUnstable.nix;
          nix.channel.enable = false;
          nix.settings.experimental-features = "nix-command";
          nix.settings.nix-path = [ "nixpkgs=${builtins.storePath sources.pkgs.path}" ];
        };
      };
    };
}
