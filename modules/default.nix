{ sources, ... }:
let
  files = builtins.attrNames (builtins.readDir ./.);
  modules = builtins.filter (
    m:
    builtins.trace "The current directory is ${toString m}" (
      builtins.readFileType ./${m} == "directory"
    )
  ) files;
  modulesImports = map (
    m: builtins.trace "About to import ${m}" (import ./${m} { inherit sources; })
  ) modules;
in
[ (import ./hardware { inherit sources; }) ]
