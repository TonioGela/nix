{ sources, modules }:
let
  stateVersion = "25.11";

  commonHomeManagerSettings = {
    _module.args.pkgsUnstable = sources.pkgsUnstable;

    programs.home-manager.enable = true;
    home.enableNixpkgsReleaseCheck = true;
    home.stateVersion = stateVersion;
  };

  # This get passed both to nixos and home-manager modules
  specialArgs = { inherit sources modules; };
in
{
  nixos =
    system: config:
    sources.nixosBuilder {
      inherit system specialArgs;
      configuration = {
        imports = [
          sources.homeManager
          (import config)
        ];

        config = {
          _module.args.pkgsUnstable = sources.pkgsUnstable;

          nixpkgs.pkgs = sources.pkgs;
          system.stateVersion = stateVersion;

          nix = {
            package = sources.pkgsUnstable.nix;
            nixPath = [ "nixpkgs=${builtins.storePath sources.pkgs.path}" ];
            channel.enable = false;
            settings.experimental-features = [ "nix-command" ];
            optimise = {
              automatic = true;
              persistent = true;
              dates = "weekly";
            };
          };

          home-manager = {
            useGlobalPkgs = true; # use system's nixpkgs
            useUserPackages = true; # installs user packages via users.users.<name>.packages
            extraSpecialArgs = specialArgs;
            sharedModules = [ commonHomeManagerSettings ];
          };
        };
      };
    };

  home-manager =
    config:
    sources.homeManagerBuilder {
      pkgs = sources.pkgs;
      extraSpecialArgs = specialArgs;
      configuration = {
        imports = [
          commonHomeManagerSettings
          (import config)
        ];

        config = {
          nix.package = sources.pkgsUnstable.nix;
          nix.settings.experimental-features = [ "nix-command" ];
          nix.nixPath = [ "nixpkgs=${builtins.storePath sources.pkgs.path}" ];
        };
      };
    };
}
