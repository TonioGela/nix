{
  pkgs,
  config,
  sources,
  ...
}:
{
  imports = [ sources.sops ];
  config = {
    home.packages = [ pkgs.sops ];
    sops = {
      defaultSopsFile = ./secrets.yml;
      gnupg.home = config.programs.gpg.homedir;
      age.sshKeyPaths = [ ];
    };
  };
}
