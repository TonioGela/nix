{ home-manager-modules, sources, ... }:
{

  environment.systemPackages = with sources.pkgs; [ ripdrag ];
  home-manager.sharedModules = [
    {
      imports = [ home-manager-modules.yazi ];
    }
  ];
}
