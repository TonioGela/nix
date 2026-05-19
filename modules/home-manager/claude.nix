{ config, pkgsUnstable, ... }:
{
  home.packages = [ pkgsUnstable.claude-code ];
  home.sessionVariables.CLAUDE_CONFIG_DIR = "${config.home.homeDirectory}/.config/claude";
}
