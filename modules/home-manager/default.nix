let
  filterAttrs =
    pred: set:
    removeAttrs set (builtins.filter (name: !pred name set.${name}) (builtins.attrNames set));
  modules = filterAttrs (key: value: value == "directory") (builtins.readDir ./.);
  modulesImports = map (m: import ./${m}) (builtins.attrNames modules);
in
modulesImports
