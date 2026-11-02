{
  pkgs,
  lib,
  sources,
  pkgsUnstable,
  config,
  ...
}:
# Add extra args to the generated commands so that shit can be overridden
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
      installable = lib.mkOption {
        type = lib.types.bool;
        description = "Whether to add a $configurationName.install command that WIPES targetHost and installs the config with nixos-anywhere (needs disko)";
        default = false;
      };    };
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
  installTemplate =
    dm:
    pkgs.writeShellScriptBin "${dm.configurationName}.install" ''
      nixos-anywhere --store-paths $(nix-build ${dm.configurationPath} -A ${dm.configurationName}.config.system.build.diskoScript -A ${dm.configurationName}.config.system.build.toplevel --no-out-link) "$@" root@${dm.targetHost}
    '';
  # iets classic mode in front of the real nix; whatever iets doesn't implement falls back to config.nix.package
  ietsNix = sources.iets.lib.mkClassic pkgs
    sources.iets.packages.${pkgs.stdenv.hostPlatform.system}.default
    config.nix.package;
  # nom's --log-format internal-json makes iets fall back to nix, so builds get --no-nom
  ietsNh = pkgs.writeShellScriptBin "nh" ''
    export PATH=${ietsNix}/bin:$PATH
    case "$1 $2" in
      "os switch" | "os boot" | "os test" | "os build" | "home switch" | "home build")
        a=$1 b=$2
        shift 2
        set -- "$a" "$b" --no-nom "$@"
        ;;
    esac
    exec ${pkgsUnstable.nh}/bin/nh "$@"
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
    programs.nh.useIets = lib.mkEnableOption "running nh's nix calls through iets (github:numtide/iets)";
  };

  imports = [ sources.nix-index-database ];

  config = {
    programs.nix-index-database.comma.enable = true;
    home.shellAliases.",," = "NIX_PATH=nixpkgs=${builtins.storePath pkgsUnstable.path} ,";

    programs.nh = {
      enable = true;
      package =
        if config.programs.nh.useIets then
          # ietsNh first so its bin/nh shadows the real one; completions etc. come from nh
          pkgs.symlinkJoin {
            name = "nh-iets";
            meta.mainProgram = "nh";
            paths = [
              ietsNh
              pkgsUnstable.nh
            ];
          }
        else
          pkgsUnstable.nh;
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
      pkgsUnstable.nix-output-monitor
      pkgsUnstable.nix-tree
      pkgsUnstable.nix-diff
      pkgsUnstable.vulnix
      pkgsUnstable.npins
      pkgsUnstable.nixos-anywhere
      pkgsUnstable.deadnix
      pkgsUnstable.statix
    ]
    ++ lib.concatMap (
      dm:
      map (command: commandTemplate dm command) commands
      ++ lib.optional dm.installable (installTemplate dm)
    )config.programs.nh.deployments;
  };
}
