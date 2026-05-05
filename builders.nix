{ sources, modules }:
{
  nixos =
    system: config:
    sources.nixosBuilder {
      inherit system;
      specialArgs = {
        home-manager-modules = modules.home-manager;
        inherit sources;
      };
      configuration = {
        imports = [
          (import config { inherit sources modules; })
          sources.homeManager
        ];

        nixpkgs.pkgs = sources.pkgs;

        nix = {
          channel.enable = false;
          settings.experimental-features = [ "nix-command" ];
          nixPath = [
            "nixpkgs=${builtins.storePath sources.pkgs.path}"
            "nixos-config=/etc/nixos/configuration.nix"
          ];
        };

        system.copySystemConfiguration = true;
        system.stateVersion = "25.11";

        environment.systemPackages = with sources.pkgs; [
          git
          nh
          npins
        ];

        time.timeZone = "Europe/Rome";
        fonts.packages = [ sources.pkgs.nerd-fonts.sauce-code-pro ];
        i18n = {
          defaultLocale = "en_GB.UTF-8";
          extraLocales = [ "it_IT.UTF-8/UTF-8" ];
        };

        home-manager = {
          useGlobalPkgs = true; # use system's nixpkgs
          useUserPackages = true; # installs user packages via users.users.<name>.packages
          sharedModules = [
            {
              _module.args = {
                pkgsUnstable = sources.pkgsUnstable;
              };
              home.enableNixpkgsReleaseCheck = true;
              programs.home-manager.enable = true;
              home.stateVersion = "25.11";
            }
          ];
        };
      };
    };
  home-manager =
    config:
    sources.homeManagerBuilder {
      pkgs = sources.pkgs;
      configuration = {
        imports = [ (import config { inherit sources modules; }) ];
        config._module.args = {
          pkgsUnstable = sources.pkgsUnstable;
        };
      };
    };
}
