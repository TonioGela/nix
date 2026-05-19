{

  home-manager.sharedModules = [
    (
      { lib, config, ... }:
      {
        home.activation = {
          rmSomeThing = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            rm -rf ${config.home.homeDirectory}.nix-defexpr
            rm -rf ${config.home.homeDirectory}/.nix-profile
          '';
        };
      }
    )
  ];
}
