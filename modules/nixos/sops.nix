# Machine secrets live in machines/<name>/secrets.yml (set sops.defaultSopsFile), decrypted
# at activation with the machine's passwordless gpg key in /var/lib/sops/gnupg. Without the
# key the system still boots, only the units that need the secrets fail.
{ sources, ... }:
{
  imports = [ sources.sopsNixos ];

  sops.gnupg.home = "/var/lib/sops/gnupg";
  sops.gnupg.sshKeyPaths = [ ];
  sops.age.sshKeyPaths = [ ];
}
