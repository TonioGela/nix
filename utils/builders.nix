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

        _module.args = {
          pkgsUnstable = sources.pkgsUnstable;
        };

        nixpkgs.pkgs = sources.pkgs;

        nix = {
          package = sources.pkgsUnstable.nix;
          channel.enable = false;
          settings.experimental-features = [ "nix-command" ];
          nixPath = [
            "nixpkgs=${builtins.storePath sources.pkgs.path}"
          ];
          optimise = {
            automatic = true;
            persistent = true;
            dates = "weekly";
          };
        };

        system.copySystemConfiguration = true;
        system.stateVersion = "25.11";

        time.timeZone = "Europe/Rome";
        fonts.packages = [ sources.pkgs.nerd-fonts.sauce-code-pro ];
        i18n = {
          defaultLocale = "en_GB.UTF-8";
          extraLocales = [ "it_IT.UTF-8/UTF-8" ];
        };

        home-manager = {
          useGlobalPkgs = true; # use system's nixpkgs
          useUserPackages = true; # installs user packages via users.users.<name>.packages
          extraSpecialArgs = { inherit sources; };
          sharedModules = [
            {
              _module.args = {
                pkgsUnstable = sources.pkgsUnstable;
              };
              home = {
                enableNixpkgsReleaseCheck = true;
                stateVersion = "25.11";
              };
              programs.home-manager.enable = true;
            }
          ];
        };
      };
    };

  home-manager =
    config:
    sources.homeManagerBuilder {
      pkgs = sources.pkgs;
      extraSpecialArgs = { inherit sources; };
      configuration = {
        imports = [ (import config { inherit sources modules; }) ];
        config = {
          _module.args = {
            pkgsUnstable = sources.pkgsUnstable;
          };
          home = {
            enableNixpkgsReleaseCheck = true;
            stateVersion = "25.11";
          };
          programs.home-manager.enable = true;
          nix = {
            package = sources.pkgs.nix;
            settings = {
              experimental-features = "nix-command";
              nix-path = [
                "nixpkgs=${builtins.storePath sources.pkgs.path}"
              ];
            };
          };
        };
      };
    };
}
