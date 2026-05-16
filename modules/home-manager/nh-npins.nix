{
  lib,
  pkgsUnstable,
  config,
  ...
}:
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
  };

  config = {
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

    home.packages = [ pkgsUnstable.npins ];
  };
}
