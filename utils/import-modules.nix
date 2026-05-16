path:
let
  # lib.strings.removeSuffix
  removeSuffix =
    suffix: str:
    (
      let
        sufLen = builtins.stringLength suffix;
        sLen = builtins.stringLength str;
      in
      if sufLen <= sLen && suffix == builtins.substring (sLen - sufLen) sufLen str then
        builtins.substring 0 (sLen - sufLen) str
      else
        str
    );

  moduleNames = builtins.attrNames (builtins.readDir path);
  modulesList = map (m: {
    name = removeSuffix ".nix" m;
    value = (import (path + "/${m}"));
  }) moduleNames;
in
builtins.listToAttrs modulesList
