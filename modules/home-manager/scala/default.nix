{
  pkgs,
  pkgsUnstable,
  config,
  ...
}:
let
  jdk = pkgs.jdk17_headless; # The non headless includes AWS, Swing and such
  extra_plugins_path = ".config/sbt/extra_plugins.sbt";
  extra_plugins_absolute_path = "${config.home.homeDirectory}/${extra_plugins_path}";
in
{
  home.packages = [
    jdk
    (pkgsUnstable.scala-cli.overrideAttrs { jre = jdk; })
    (pkgsUnstable.sbt.overrideAttrs { jre = jdk; })
    (pkgsUnstable.bloop.overrideAttrs { jre = jdk; })
    (pkgsUnstable.scalafmt.overrideAttrs { jre = jdk; })
    (pkgsUnstable.scalafix.overrideAttrs { jre8 = jdk; })
  ];

  programs.java = {
    enable = true;
    package = jdk;
  };

  programs.zsh.shellAliases = {
    sbt = ''sbt --addPluginSbtFile="${extra_plugins_absolute_path}"'';
    sbtn = ''sbtn --addPluginSbtFile="${extra_plugins_absolute_path}"'';
  };

  home.file."${extra_plugins_path}".source = ./extra_plugins.sbt;
}
