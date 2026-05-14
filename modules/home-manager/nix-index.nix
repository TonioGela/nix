{ sources, ... }:
{
  imports = [ sources.nix-index-database ];
  config.programs.nix-index-database.comma.enable = true;
}
