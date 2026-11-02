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
  home.sessionVariables.NODE_EXTRA_CA_CERTS = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
}
