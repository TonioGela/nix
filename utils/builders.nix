{ sources, modules }:
let
  stateVersion = "26.05";
  specialArgs = { inherit sources modules; };

  # Passed as a nixos module to nixos and as a hm module to hm
  commonNixSettings =
    { pkgs, pkgsUnstable, ... }:
    {
      nix.package = pkgsUnstable.nixVersions.latest;
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

  pkgsForSystem =
    system: p:
    import p.path {
      inherit system;
      config.allowUnfree = true;
    };

  pkgsFor = system: pkgsForSystem system sources.pkgs;
  pkgsUnstableFor = system: pkgsForSystem system sources.pkgsUnstable;

  # Passed as a hm module to both builders but also as a nixos module to nixos
  additionsModuleArgs = pkgsUnstable: {
    _module.args.pkgsUnstable = pkgsUnstable;
  };

  # Passed as a hm module to both builders
  commonHomeManagerSettings = pkgsUnstable: {
    imports = [ (additionsModuleArgs pkgsUnstable) ];
    programs.home-manager.enable = true;
    home.enableNixpkgsReleaseCheck = true;
    home.stateVersion = stateVersion;
  };
in
{
  nixos =
    system: config:
    let
      pkgs = pkgsFor system;
      pkgsUnstable = pkgsUnstableFor system;
    in
    sources.nixosBuilder {
      inherit system specialArgs;
      configuration = {
        imports = [
          sources.homeManager
          commonNixSettings
          (additionsModuleArgs pkgsUnstable)
          config
        ];

        config = {
          nixpkgs.pkgs = pkgs;
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
            sharedModules = [ (commonHomeManagerSettings pkgsUnstable) ];
          };
        };
      };
    };

  home-manager =
    system: config:
    let
      pkgs = pkgsFor system;
      pkgsUnstable = pkgsUnstableFor system;
    in
    sources.homeManagerBuilder {
      inherit pkgs;
      extraSpecialArgs = specialArgs;
      configuration = {
        imports = [
          (commonHomeManagerSettings pkgsUnstable)
          commonNixSettings
          config
        ];

        # Home Manager doesn't inherit it from the externally created instance
        config.nixpkgs.config.allowUnfree = true;
        config.nixpkgs.overlays = [ sources.nix-vscode-extensions ];
      };
    };
}
