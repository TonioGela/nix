{ home-manager-modules, sources, ... }:
{
  programs.zsh.enable = true;
  programs.zoxide.enable = true; # TODO is it needed?
  users.defaultUserShell = sources.pkgs.zsh;

  home-manager.sharedModules = [
    {
      imports = [ home-manager-modules.zsh ];
    }
  ];
}
