{ pkgs, ... }:
{
  home.packages = [
    (pkgs.pass.withExtensions (exts: [
      exts.pass-otp
      exts.pass-update
      exts.pass-audit
      exts.pass-genphrase
      exts.pass-file
    ]))
  ];
}
