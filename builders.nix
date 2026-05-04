{ sources, modules }:
{
  nixos =
    system: config:
    sources.nixosBuilder {
      inherit system;
      configuration = {
        imports = [
          (import config { inherit sources modules; })
          sources.homeManager
        ];
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
        system.copySystemConfiguration = true;
        system.stateVersion = "25.11";
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
