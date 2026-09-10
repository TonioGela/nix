{
  config,
  pkgs,
  pkgsUnstable,
  ...
}:
{
  home.packages = [
    pkgsUnstable.claude-code
    pkgs.nodejs_26
  ];
  home.sessionVariables.CLAUDE_CONFIG_DIR = "${config.home.homeDirectory}/.config/claude";
}
