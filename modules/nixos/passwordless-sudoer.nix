{ pkgs, config, ... }: {
  options = {
    passwordlessSudoer = pkgs.lib.mkOption {
      type = pkgs.lib.types.str;
      description = "name of the user to become a passworless sudoer";
    };
  };

  config = {
    users.users.${config.passwordlessSudoer} = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
    };

    security.sudo.extraRules = [
      {
        users = [ "${config.passwordlessSudoer}" ];
        commands = [
          {
            command = "ALL";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };
}
