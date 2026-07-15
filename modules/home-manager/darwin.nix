{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (builtins)
    filter
    readDir
    concatMap
    attrNames
    replaceStrings
    concatStringsSep
    ;

  installMasCommand = concatStringsSep "\n" (
    map (id: "${lib.getExe' pkgs.mas "mas"} install ${id} 2>/dev/null") config.darwin.masAppIds
  );
  desktopApps = filter (x: (readDir x.outPath) ? Applications) config.home.packages;
  appPaths = concatMap (
    x: map (n: "${x.outPath}/Applications/${n}") (attrNames (readDir "${x.outPath}/Applications"))
  ) desktopApps;
  fancyPath = x: "Macintosh HD" + (replaceStrings [ "/" ] [ ":" ] x);
  destinationPath = "${config.home.homeDirectory}/Applications/Home Manager Apps";
  refreshCommand = ''
    /usr/bin/osascript -e 'tell application "Finder" to update folder "${fancyPath destinationPath}"'
  '';
  commandF = x: ''
    /usr/bin/osascript -e 'tell application "Finder" to make alias file to file "${x}" at "${fancyPath destinationPath}"' >/dev/null
  '';
  creationCommands = concatStringsSep "\n" (map commandF (map fancyPath appPaths));
  # The sleep is due to the fact that Finder might need some time to release some internal metadata and actually free the name
  command = ''
    rm -rf "${destinationPath}"
    sleep 1
    mkdir -p "${destinationPath}"
    ${refreshCommand}
    ${creationCommands}
  '';
in
{

  options = {
    darwin.masAppIds = pkgs.lib.mkOption {
      type = pkgs.lib.types.listOf pkgs.lib.types.str;
      description = "Mac App Store application ids to install via mas";
      default = [ ];
    };
  };

  config = {
    home.packages = lib.lists.optional (config.darwin.masAppIds != [ ]) pkgs.mas;
    home.activation."Mac App Store Apps" = lib.hm.dag.entryAfter [ "writeBoundary" ] installMasCommand;
    home.activation."Desktop Apps" = lib.hm.dag.entryAfter [ "writeBoundary" ] command;

    targets.darwin.linkApps.enable = false;

    # https://macos-defaults.com/
    targets.darwin.defaults = {
      "org.gpgtools.common".UseKeychain = false;
      "com.apple.dock" = {
        orientation = "bottom";
        autohide = true;
        tilesize = 64;
        autohide-time-modifier = 0.5;
        autohide-delay = 0.2;
        show-recent = 0;
        mineffect = "scale";
      };
      "com.apple.finder" = {
        QuitMenuItem = false;
        AppleShowAllExtensions = true;
        ShowPathbar = false;
        ShowStatusBar = false;
        FXPreferredViewStyle = "Nlsv";
        _FXSortFoldersFirst = true;
        FXRemoveOldTrashItems = true;
        FXEnableExtensionChangeWarning = false;
        NSDocumentSaveNewDocumentsToCloud = false;
        ShowHardDrivesOnDesktop = false;
        ShowExternalHardDrivesOnDesktop = true;
        ShowRemovableMediaOnDesktop = true;
        ShowMountedServersOnDesktop = false;
        NewWindowTarget = "PfHm";
        DesktopViewSettings.IconViewSettings.arrangeBy = "grid";
      };
      "com.apple.desktopservices" = {
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };
      "com.apple.universalaccess" = {
        showWindowTitlebarIcons = false;
      };
      NSGlobalDomain = {
        NSTableViewDefaultSizeMode = 1;
      };
      # Apple intelligence
      "com.apple.CloudSubscriptionFeatures.optIn"."545129924" = false;
      "com.apple.TextInputMenu".visible = false;
      "com.apple.TextInputMenuAgent"."NSStatusItem VisibleCC Item-0" = false;
    };
  };
}
