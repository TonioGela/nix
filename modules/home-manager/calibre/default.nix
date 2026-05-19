{ pkgs, lib, ... }:
{
  home.packages = [
    (pkgs.calibre.overrideAttrs (old: {
      postFixup = (old.postFixup or "") + ''
        wrapProgram $out/bin/calibre \
          --set ACSM_LIBCRYPTO ${lib.getLib pkgs.libressl}/lib/libcrypto.so \
          --set ACSM_LIBSSL    ${lib.getLib pkgs.libressl}/lib/libssl.so
      '';
    }))
  ];

  xdg.desktopEntries = {
    calibre-ebook-edit = {
      name = "E-book editor";
      noDisplay = true;
    };
    calibre-ebook-viewer = {
      name = "E=book viewer";
      noDisplay = true;
    };
    calibre-lrfviewer = {
      name = "LRF viewer";
      noDisplay = true;
    };
  };
}

# Download the plugin and import it into Calibre, then open the plugin settings. The plugin should
# display "Not authorized for any ADE ID". You now have multiple options to authorize the plugin:
# - You can click on "Link to ADE account" and enter your AdobeID credentials to link your Calibre
#   installation to your AdobeID account. This uses up one of your available activations.
# - You can click on "Create anonymous authorization" to create an anonymous authorization. Make
#   sure to create backups of that authorization.
# - If you have ADE installed and activated on your machine, you can click "Import activation from
#   ADE" to clone the existing activation from your ADE installation.
# - If you have used this plugin before, you can click on "Import existing activation backup" to
#   import a previously created activation backup (ZIP) file to restore an activation. This
#   functionality can also be used to clone one activation to multiple computers.

# During authorization, the plugin may ask you for the ADE version to emulate. Usually you can
# leave this setting as it is (ADE 2.0.1).
# After you've activated the plugin, make a backup of the activation using the "Export account
# activation data". Then click "Export account encryption key" and import the resulting file into
# the DeDRM plugin for DRM removal. If you're using noDRM's fork of the DeDRM plugin, this step will
# happen automatically. If you don't have the DeDRM plugin set up (or you're not using noDRM's fork
# and didn't import the key file) you will not be able to read the downloaded books in Calibre due
# to the DRM.
# Once that's done, download an ACSM file from Adobe's test library and see if you can import it
# into Calibre: https://www.adobe.com/de/solutions/ebook/digital-editions/sample-ebook-library.html
