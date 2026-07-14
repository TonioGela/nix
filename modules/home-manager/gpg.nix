{
  pkgs,
  config,
  ...
}:
{

  options = {
    gpg.sshKeys = pkgs.lib.mkOption {
      type = pkgs.lib.types.listOf pkgs.lib.types.str;
      description = "The list of ssh keys to add to the gpg-agent";
      default = [ ];
    };
    gpg.defaultSigningKeyId = pkgs.lib.mkOption {
      type = pkgs.lib.types.nullOr pkgs.lib.types.str;
      description = "programs.gpg.settings.default-key";
      default = null;
    };
    gpg.trustedKeyId = pkgs.lib.mkOption {
      type = pkgs.lib.types.nullOr pkgs.lib.types.str;
      description = "programs.gpg.settings.trusted-key";
      default = null;
    };
  };

  config = {

    home.packages = [
      pkgs.zbar
      pkgs.paperkey
      pkgs.qrencode
    ];

    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      enableZshIntegration = true;
      pinentry.package = if pkgs.stdenv.isLinux then pkgs.pinentry-gnome3 else pkgs.pinentry_mac;
      sshKeys = config.gpg.sshKeys;
    };

    # https://tsawyer87.github.io/posts/gpg-agent_on_nixos/
    programs.gpg = {
      ## Enable GnuPG
      enable = true;
      homedir = "${config.home.homeDirectory}/.local/state/gnupg";

      settings = {
        default-key = pkgs.lib.mkIf (config.gpg.defaultSigningKeyId != null) config.gpg.defaultSigningKeyId;
        trusted-key = pkgs.lib.mkIf (config.gpg.trustedKeyId != null) config.gpg.trustedKeyId;
        personal-cipher-preferences = "AES256 AES192 AES";
        personal-digest-preferences = "SHA512 SHA384 SHA256";
        personal-compress-preferences = "ZLIB BZIP2 ZIP Uncompressed";
        default-preference-list = "SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed";
        cert-digest-algo = "SHA512";
        s2k-digest-algo = "SHA512";
        s2k-cipher-algo = "AES256";
        charset = "utf-8";
        # Show Unix timestamps
        fixed-list-mode = "";
        # No comments in signature
        no-comments = "";
        # No version in signature
        no-emit-version = "";
        # Disable banner
        no-greeting = "";
        # Long hexidecimal key format
        keyid-format = "0xlong";
        # Display UID validity
        list-options = "show-uid-validity";
        verify-options = "show-uid-validity";
        # Display all keys and their fingerprints
        with-fingerprint = "";
        # Cross-certify subkeys are present and valid
        require-cross-certification = "";
        # Disable caching of passphrase for symmetrical ops
        no-symkey-cache = "";
        # Enable smartcard
        # use-agent = "";
      };
    };
  };
}
