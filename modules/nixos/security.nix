{
  # if there's no ~/.local/share/keyrings/login.keyring you need to
  # input the password in the lockscreen or tuigreet

  # You also need a polkit agent, the noctalia plugin works decently
  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;
  services.fprintd.enable = true;
}
