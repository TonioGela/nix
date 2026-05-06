# Do not import this manually, it's imported automatically by utils/builders.nix
{ pkgs, ... }:
{
  options = {

    git.username = pkgs.lib.mkOption {
      type = pkgs.lib.types.str;
    };

    git.email = pkgs.lib.mkOption {
      type = pkgs.lib.types.str;
    };

    git.signingKey = pkgs.lib.mkOption {
      type = pkgs.lib.types.str;
      description = ''
        After you generate a key with `gpg --full-generate-key`
        you can see it's id with `gpg --list-secret-keys --keyid-format=long`.
        To see the public one for github/lab use `gpg --armor --export <ID>`
      '';
    };

    git.maintainedRepos = pkgs.lib.mkOption {
      type = pkgs.lib.types.listOf pkgs.lib.types.str;
      default = [ ];
    };

    additionalBookmarks = pkgs.lib.mkOption {
      type = pkgs.lib.types.listOf pkgs.lib.types.anything;
      default = [ ];
    };
  };
}
