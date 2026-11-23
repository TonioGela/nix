{ pkgs, sources, ... }:
{
  # Built with this module's pkgs, so it targets the machine's own system
  home.packages = [ (sources.todo-txt-rs pkgs) ];
}
