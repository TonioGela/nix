{ sources, modules }:
let
  stateVersion = "26.05";
  specialArgs = { inherit sources modules; };

  # Passed as a nixos module to nixos and as a hm module to hm
  commonNixSettings =
    { pkgs, pkgsUnstable, ... }:
    {
      nix.package = pkgsUnstable.nix;
      nix.settings.experimental-features = [
        "nix-command"
        "pipe-operators"
      ];
      nix.settings.trusted-users = [
        "root"
        "toniogela"
      ];
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
          config
        ];

        config = {
          nixpkgs.pkgs = sources.pkgs;
          nixpkgs.overlays = [ sources.nix-vscode-extensions ];
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
          config
        ];

        # Home Manager doesn't inherit it from the externally created instance
        config.nixpkgs.config.allowUnfree = true;
        config.nixpkgs.overlays = [ sources.nix-vscode-extensions ];
      };
    };
}
