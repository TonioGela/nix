{
  pkgs,
  lib,
  sources,
  pkgsUnstable,
  config,
  ...
}:
# Add extra args to the generated commands so that shit can be overridden
# Add a $conf.deploy command behind a boolean flag that simply calls nix-instantiate
let
  deploymentSubmodule = lib.types.submodule {
    options = {
      configurationPath = lib.mkOption {
        type = lib.types.str;
        description = "Path to the config to populate the NH_FILE variable";
        default = config.programs.nh.nhFile;
      };
      configurationName = lib.mkOption {
        type = lib.types.str;
        description = "Name of the config to populate the NH_ATTRP variable";
      };
      configurationKind = lib.mkOption {
        type = lib.types.enum [
          "nixos"
          "home-manager"
        ];
        description = "Whether the config is a nixos or a home-manager one";
      };
      targetHost = lib.mkOption { type = lib.types.str; };
      tailscale = lib.mkOption {
        type = lib.types.bool;
        description = "Whether the targetHost URI requires tailscale on to be resolved";
        default = false;
      };
      useSubstitutes = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
      elevationStrategy = lib.mkOption {
        type = lib.types.str;
        default = "passwordless";
      };
    };
  };
  commands = [
    "switch"
    "boot"
    "build"
  ];
  commandTemplate =
    dm: command:
    pkgs.writeShellScriptBin "${dm.configurationName}.${command}" ''
      NH_FILE=${dm.configurationPath} NH_ATTRP=${dm.configurationName} NH_ELEVATION_STRATEGY=${dm.elevationStrategy} nh ${
        if (dm.configurationKind == "nixos") then "os" else "home"
      } ${command} --target-host ${dm.targetHost} ${
        if (dm.useSubstitutes) then "--use-substitutes" else ""
      }
    '';
in
{
  options = {
    programs.nh.nhFile = lib.mkOption {
      type = lib.types.str;
      description = "Value for the NH_FILE variable. It should point at you configuration";
    };
    programs.nh.nhAttrPath = lib.mkOption {
      type = lib.types.str;
      description = "Value for the NH_ATTRP variable. It's the attribute path to follow to find the configuration to activate in the file";
    };
    programs.nh.deployments = lib.mkOption {
      type = lib.types.listOf deploymentSubmodule;
      description = "List of deployment targets for nh";
      default = [ ];
    };
  };

  imports = [ sources.nix-index-database ];

  config = {
    programs.nix-index-database.comma.enable = true;

    programs.nh = {
      enable = true;
      package = pkgsUnstable.nh;
      clean = {
        enable = true;
        dates = "weekly";
        extraArgs = "--keep 10 --keep-since 7d";
      };
    };

    home.sessionVariables = {
      NH_FILE = config.programs.nh.nhFile;
      NH_ATTRP = config.programs.nh.nhAttrPath;
    };

    home.packages = [
      pkgsUnstable.nix-tree
      pkgsUnstable.nix-diff
      pkgsUnstable.vulnix
      pkgsUnstable.npins
      pkgsUnstable.nixos-anywhere
    ]
    ++ lib.concatMap (
      dm: map (command: commandTemplate dm command) commands
    ) config.programs.nh.deployments;
  };
}
