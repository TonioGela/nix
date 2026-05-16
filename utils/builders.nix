{ sources, modules }:
let
  stateVersion = "25.11";
  specialArgs = { inherit sources modules; };

  # Passed as a nixos module to nixos and as a hm module to hm
  commonNixSettings =
    { pkgs, pkgsUnstable, ... }:
    {
      nix.package = pkgsUnstable.nix;
      nix.settings.experimental-features = [ "nix-command" ];
      nix.nixPath = [ "nixpkgs=${builtins.storePath pkgs.path}" ];
    };

  # Passed as a hm module to both builders but also as a nixos module to nixos
  additionsModuleArgs = {
    _module.args.pkgsUnstable = sources.pkgsUnstable;
  };

  # Passed as a hm module to both builders
  commonHomeManagerSettings = {
    imports = [ additionsModuleArgs ];
    programs.home-manager.enable = true;
    home.enableNixpkgsReleaseCheck = true;
    home.stateVersion = stateVersion;
  };
in
{
  nixos =
    system: config:
    sources.nixosBuilder {
      inherit system specialArgs;
      configuration = {
        imports = [
          sources.homeManager
          commonNixSettings
          additionsModuleArgs
          (import config)
        ];

        config = {
          nixpkgs.pkgs = sources.pkgs;
          system.stateVersion = stateVersion;

          nix.channel.enable = false;
          nix.optimise = {
            automatic = true;
            persistent = true;
            dates = "weekly";
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
          commonNixSettings
          (import config)
        ];
      };
    };
}
