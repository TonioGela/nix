{ pkgs, ... }:
{
  # https://tsawyer87.github.io/posts/gpg-agent_on_nixos/
  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    enableZshIntegration = true;
    pinentry.package = if pkgs.stdenv.isLinux then pkgs.pinentry-gnome3 else pkgs.pinentry_mac;
  };
}
