{ sources, home-manager-modules, ... }:
let
  # lib.filterAttrs
  filterAttrs =
    pred: set:
    removeAttrs set (builtins.filter (name: !pred name set.${name}) (builtins.attrNames set));
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

  modules = filterAttrs (key: value: key != "default.nix") (builtins.readDir ./.);
  modulesList = map (m: {
    name = removeSuffix ".nix" m;
    value = (import ./${m} { inherit sources home-manager-modules; });
  }) (builtins.attrNames modules);
in
builtins.listToAttrs modulesList
