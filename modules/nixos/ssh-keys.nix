let
  key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILWwmMYuP1GUPSBRiven+ia4YQhwoNXNyjw6OOTYL/Md openpgp:0x1BF7ACA9";
  users = [
    "toniogela"
    "root"
  ];
in
{
  users.users = builtins.listToAttrs (
    map (u: {
      name = u;
      value.openssh.authorizedKeys.keys = [ key ];
    }) users
  );
}
