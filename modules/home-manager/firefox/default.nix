{
  pkgs,
  config,
  ...
}:
let
  bookmarksSort =
    items:
    map
      (
        item:
        if builtins.hasAttr "bookmarks" item then
          item // { bookmarks = bookmarksSort item.bookmarks; }
        else
          item
      )
      (
        builtins.sort (
          a: b:
          let
            isFolderA = builtins.hasAttr "bookmarks" a;
            isFolderB = builtins.hasAttr "bookmarks" b;
          in
          if isFolderA && !isFolderB then
            true
          else if !isFolderA && isFolderB then
            false
          else
            a.name < b.name
        ) items
      );
in
{
  options = {
    firefox.additionalBookmarks = pkgs.lib.mkOption {
      type = pkgs.lib.types.listOf pkgs.lib.types.anything;
      default = [ ];
    };

    firefox.additionalExtensions = pkgs.lib.mkOption {
      type = pkgs.lib.types.listOf (
        pkgs.lib.types.submodule {
          options = {
            shortId = pkgs.lib.mkOption { type = pkgs.lib.types.str; };
            uuid = pkgs.lib.mkOption { type = pkgs.lib.types.str; };
          };
        }
      );
      description = ''
        To add additional extensions, find it on addons.mozilla.org, find the short ID in the url (like https://addons.mozilla.org/en-US/firefox/addon/!SHORT_ID!/)
        Then install it manually and go to about:debugging#/runtime/this-firefox to get the uuid
      '';
      default = [ ];
    };
  };

  config = {
    home.file.".config/tridactyl/tridactylrc".text = ''
      " This wipes all existing settings. This means that if a setting in this file
      " is removed, then it will return to default. In other words, this file serves
      " as an enforced single point of truth for Tridactyl's configuration.
      sanitize tridactyllocal tridactylsync

      set update.lastchecktime 1784128384688
      set configversion 2.0

      "" Styling
      set theme dark
      "" Not working, replaced with css in usercontent
      set modeindicatormodes {"normal":"false","insert":"true","input":"true","ignore":"true","ex":"true","hint":"true","visual":"true"} 

      " Tridactyl search
      bind / fillcmdline find
      bind ? fillcmdline find -?
      bind n findnext 1
      bind N findnext -1
      " Remove search highlighting.
      bind ,<Space> nohlsearch
      " Use sensitive case. Smart case would be nice here, but it doesn't work.
      set findcase sensitive

      " Smooth scrolling, yes please. This is still a bit janky in Tridactyl.
      set smoothscroll true
      " The default jump of 10 is a bit much.
      bind j scrollline 5
      bind k scrollline -5

      bind gh js document.evaluate("//a[contains(text(), 'Add to favorites')]", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.click()

      " Disable all searchurls
      jsb Object.keys(tri.config.get("searchurls")).reduce((prev, u) => prev.catch(()=>{}).then(_ => tri.excmds.setnull("searchurls." + u)), Promise.resolve())
      " Add our own
      set searchurls.ddg https://duckduckgo.com/html?q=%s
      set searchurls.g https://www.google.com/search?q=%s
      set searchurls.gh https://github.com/search?utf8=%E2%9C%93&q=%s&ref=simplesearch
      set searchurls.gi https://www.google.com/search?q=%s&tbm=isch
      set searchurls.gmaps https://www.google.com/maps/search/%s
      set searchurls.y https://www.youtube.com/results?search_query=%s
    '';

    programs.firefox = {
      enable = true;
      languagePacks = [ "en-GB" ];
      nativeMessagingHosts = [
        pkgs.tridactyl-native
        (pkgs.passff-host.overrideAttrs (old: {
          dontStrip = true;
          patchPhase = ''
            sed -i 's#COMMAND = "pass"#COMMAND = "${
              pkgs.pass.withExtensions (ext: with ext; [ pass-otp ])
            }/bin/pass"#' src/passff.py
          '';
        }))
      ];
      policies = {
        BlockAboutConfig = false;
        BlockAboutAddons = false;
        DefaultDownloadDirectory = "${config.home.homeDirectory}/Downloads";
        DisablePocket = true;
        DisableFirefoxAccounts = true;
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        DisableProfileImport = true;
        DisplayBookmarksToolbar = "never";
        DisplayMenuBar = "default-off";
        DontCheckDefaultBrowser = true;
        SearchBar = "unified";
        SearchSuggestEnabled = false;
        PromptForDownloadLocation = false;
        Homepage = {
          URL = "https://dashboard.toniogela.dev";
          Locked = true;
          Additional = [ ];
          StartPage = "homepage";
        };
        HttpsOnlyMode = "enabled";
        NewTabPage = false;
        NoDefaultBookmarks = false;
        PasswordManagerEnabled = false;
        PictureInPicture = {
          Enabled = false;
          Locked = false;
        };
        SanitizeOnShutdown = {
          Cache = true;
          Cookies = false;
          Downloads = true;
          FormData = true;
          History = false;
          Sessions = false;
          SiteSettings = false;
          OfflineApps = true;
          Locked = true;
        };
        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };
        FirefoxHome = {
          Search = false;
          TopSites = false;
          SponsoredTopSites = false;
          Highlights = false;
          Pocket = false;
          SponsoredPocket = false;
          Snippets = false;
          Locked = true;
        };
        FirefoxSuggest = {
          WebSuggestions = false;
          SponsoredSuggestions = false;
          ImproveSuggest = false;
          Locked = true;
        };
        SearchEngines = {
          PreventInstalls = true;
        };
        UserMessaging = {
          ExtensionRecommendations = false; # Don’t recommend extensions while the user is visiting web pages
          FeatureRecommendations = false; # Don’t recommend browser features
          Locked = true; # Prevent the user from changing user messaging preferences
          MoreFromMozilla = false; # Don’t show the “More from Mozilla” section in Preferences
          SkipOnboarding = true; # Don’t show onboarding messages on the new tab page
          UrlbarInterventions = false; # Don’t offer suggestions in the URL bar
          WhatsNew = false; # Remove the “What’s New” icon and menuitem
        };
        ExtensionSettings =
          with builtins;
          let
            extension = shortId: uuid: {
              name = uuid;
              value = {
                install_url = "https://addons.mozilla.org/en-US/firefox/downloads/latest/${shortId}/latest.xpi";
                installation_mode = "force_installed";
                default_area = "menupanel";
              };
            };
          in
          listToAttrs (
            [
              (extension "ublock-origin" "uBlock0@raymondhill.net")
              (extension "new-tab-override" "newtaboverride@agenedia.com")
              (extension "sponsorblock" "sponsorBlocker@ajay.app")
              (extension "single-file" "{531906d3-e22f-4a6c-a102-8057b88a1a63}")
              (extension "istilldontcareaboutcookies" "idcac-pub@guus.ninja")
              (extension "decentraleyes" "jid1-BoFifL9Vbdl2zQ@jetpack")
              (extension "watchmarker-for-youtube" "yourect@coderect.com")
              (extension "duckduckgo-for-firefox" "jid1-ZAdIEUB7XOzOJw@jetpack")
              (extension "netflix-prime-auto-skip" "NetflixPrime@Autoskip.io")
              (extension "nord-firefox" "{f4c9e1d6-6630-4600-ad50-d223eab7f3e7}")
              (extension "clearurls" "{74145f27-f039-47ce-a470-a662b129930a}")
              (extension "tridactyl-vim" "tridactyl.vim@cmcaine.co.uk")
              (extension "passff" "passff@invicem.pro")
            ]
            ++ map (e: (extension e.shortId e.uuid)) config.firefox.additionalExtensions
          );

        # To add additional extensions, find it on addons.mozilla.org, find
        # the short ID in the url (like https://addons.mozilla.org/en-US/firefox/addon/!SHORT_ID!/)
        # Then install it manually and go to about:debugging#/runtime/this-firefox to get the uuid
        "3rdparty".Extensions = {
          "uBlock0@raymondhill.net".adminSettings = {
            # userSettings = {
            #   uiTheme = "dark";
            #   uiAccentCustom = true;
            #   uiAccentCustom0 = "#8300ff";
            #   cloudStorageEnabled = false;
            #   importedLists = [ ];
            #   externalLists = ''
            #     https://filters.adtidy.org/extension/ublock/filters/3.txt
            #     https://github.com/DandelionSprout/adfilt/raw/master/LegitimateURLShortener.txt
            #   '';
            # };
            # selectedFilterLists = [
            #   "CZE-0"
            #   "adguard-generic"
            #   "adguard-annoyance"
            #   "adguard-social"
            #   "adguard-spyware-url"
            #   "easylist"
            #   "easyprivacy"
            #   "plowe-0"
            #   "ublock-abuse"
            #   "ublock-badware"
            #   "ublock-filters"
            #   "ublock-privacy"
            #   "ublock-quick-fixes"
            #   "ublock-unbreak"
            #   "urlhaus-1"
            # ];
          };
        };
      };
      profiles.default = {
        id = 0;
        name = "Default";
        bookmarks = {
          force = true;
          settings = bookmarksSort (config.firefox.additionalBookmarks ++ import ./bookmarks.nix);
        };
        extraConfig = "";
        search = {
          force = true;
          default = "ddg";
          privateDefault = "ddg";
          order = [
            "ddg"
            "google"
          ];
          engines = {
            # "NixOS Wiki" = {
            #   urls = [ { template = "https://wiki.nixos.org/index.php?search={searchTerms}"; } ];
            #   icon = "https://wiki.nixos.org/favicon.png";
            #   updateInterval = 24 * 60 * 60 * 1000; # every day
            #   definedAliases = [ "@nw" ];
            # };
            "bing".metaData.hidden = true;
            "ecosia".metaData.hidden = true;
            "qwant".metaData.hidden = true;
            "wikipedia".metaData.hidden = true;
            "google".metaData.alias = "g";
          };
        };
        settings = {
          "font.name.serif.x-western" = "SauceCodePro Nerd Font Propo";
          "font.name.sans-serif.x-western" = "SauceCodePro Nerd Font Propo";
          "font.name.monospace.x-western" = "SauceCodePro Nerd Font Propo";
          "layout.css.prefers-color-scheme.content-override" = 0;
          "browser.ml.linkPreview.enabled" = false;
          "browser.ml.enable" = false;
          "browser.ml.chat.enabled" = false;
          "browser.ml.chat.menu" = false;
          "sidebar.revamp" = true;
          "sidebar.verticalTabs" = false;
          "sidebar.visibility" = "hide-sidebar";
          "browser.startup.page" = 3;
          "browser.sessionstore.resume_from_crash" = true;
          "browser.sessionstore.max_resumed_crashes" = -1;
          "browser.aboutConfig.showWarning" = false;
          "browser.uidensity" = 1;
          "browser.translations.select.enable" = false;
          "screenshots.browser.component.enabled" = false;
          "dom.text_fragments.enabled" = false;
          "dom.text-recognition.enabled" = false;
          "browser.search.visualSearch.featureGate" = false;
          "widget.macos.native-context-menus" = false;
          "devtools.accessibility.enabled" = false;
          "privacy.query_stripping.strip_on_share.enabled" = false;
          "browser.search.suggest.enabled" = "lock-false";
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          "browser.urlbar.quickactions.enabled" = false;
          "browser.urlbar.quickactions.showPrefs" = false;
          "browser.urlbar.shortcuts.quickactions" = false;
          "browser.urlbar.suggest.quickactions" = false;
          "browser.urlbar.suggest.topsites" = false;
          "browser.urlbar.suggest.trending" = false;
          "browser.urlbar.suggest.weather" = false;
          "browser.urlbar.suggest.yelp" = false;
          "browser.urlbar.suggest.pocket" = false;
          "browser.urlbar.suggest.fakespot" = false;
          "media.autoplay.default" = 0;
          "extensions.update.enabled" = true;
          "extensions.webcompat.enable_picture_in_picture_overrides" = true;
          "print.print_footerleft" = "";
          "print.print_footerright" = "";
          "print.print_headerleft" = "";
          "print.print_headerright" = "";
          "privacy.donottrackheader.enabled" = true;
          "app.normandy.api_url" = "";
          "app.normandy.enabled" = false;
          "browser.discovery.enabled" = false;
          "browser.helperApps.deleteTempFileOnExit" = true;
          "browser.uitour.enabled" = false;
          "layout.testing.scrollbars.always-hidden" = true;
          "extensions.getAddons.showPane" = false;
          "extensions.htmlaboutaddons.recommendations.enabled" = false;
          "network.connectivity-service.enabled" = false;
          "datareporting.policy.dataSubmissionEnabled" = false;
          "datareporting.healthreport.uploadEnabled" = false;
          "toolkit.telemetry.unified" = false;
          "toolkit.telemetry.enabled" = false;
          "toolkit.telemetry.server" = "data:,";
          "toolkit.telemetry.archive.enabled" = false;
          "toolkit.telemetry.newProfilePing.enabled" = false;
          "toolkit.telemetry.shutdownPingSender.enabled" = false;
          "toolkit.telemetry.updatePing.enabled" = false;
          "toolkit.telemetry.bhrPing.enabled" = false;
          "toolkit.telemetry.firstShutdownPing.enabled" = false;
          "toolkit.telemetry.coverage.opt-out" = true; # [HIDDEN PREF]
          "toolkit.coverage.opt-out" = true; # [FF64+] [HIDDEN PREF]
          "toolkit.coverage.endpoint.base" = "";
          "browser.ping-centre.telemetry" = false;
          "browser.newtabpage.activity-stream.feeds.telemetry" = false;
          "browser.newtabpage.activity-stream.telemetry" = false;
          "toolkit.telemetry.reportingpolicy.firstRun" = false;
          "toolkit.telemetry.shutdownPingSender.enabledFirstsession" = false;
          "browser.vpn_promo.enabled" = false;
          "extensions.autoDisableScopes" = 0;
          "extensions.update.autoUpdateDefault" = false;
          "browser.tabs.warnOnClose" = false;
          "browser.tabs.warnOnCloseOtherTabs" = false;
          "browser.warnOnQuit" = false;
          "browser.warnOnQuitShortcut" = false;
          "devtools.chrome.enabled" = true;
          "devtools.debugger.remote-enabled" = true;
          "devtools.browsertoolbox.scope" = "parent-process";
          "browser.urlbar.trimHttps" = true;
          "browser.urlbar.trimURLs" = true;
          "security.sandbox.content.read_path_whitelist" = "/nix/store/";
          "browser.uiCustomization.state" = {
            placements = {
              widget-overflow-fixed-list = [ ];
              unified-extensions-area = [ ];
              nav-bar = [
                "back-button"
                "forward-button"
                "urlbar-container"
                "downloads-button"
                "passff_invicem_pro-browser-action"
                "fxa-toolbar-menu-button"
                "unified-extensions-button"
              ];
              toolbar-menubar = [ "menubar-items" ];
              TabsToolbar = [ ];
              vertical-tabs = [ ];
              PersonalToolbar = [ ];
            };
            seen = [ ];
            dirtyAreaCache = [ ];
            currentVersion = 24;
            newElementCount = 6;
          };
        };
        # TODO https://github.com/akkva/gwfox
        userChrome = ''
                  #fullscreen-warning,
                  .titlebar-buttonbox-container,
                  #statuspanel,
                  #vertical-spacer,
                  #context-back,
                  #context-forward,
                  #context-reload,
                  #context-stop,
                  #context-sendimage,
                  #context-setDesktopBackground,
                  #context-bookmarkpage,
                  #context-savepage,
                  #context-selectall,
                  #context-viewsource,
                  #context-inspect-a11y,
                  #context-inspect,
                  #context-media-eme-separator,
                  #context-sep-navigation,
                  #context-sep-viewsource-commands,
                  #context-sep-open,
                  #context-sep-sendlinktodevice,
                  #context-sep-copylink,
                  #context-sep-setbackground,
                  #context-sep-sharing,
                  #context-sep-highlights,
                  #context-sep-redo,
                  #context-sep-selectall,
                  #context-sep-pdfjs-redo,
                  #context-sep-pdfjs-selectall,
                  #context-sep-screenshots,
                  #context-sep-frame-screenshot,
                  #context-sep-bidi,
                  #context-media-sep-video-commands,
                  #context-media-sep-commands,
                  #frame-sep {
                    display: none !important;
                  }

                  .titlebar-spacer[type="pre-tabs"] {
                    width: 2px !important;
          	  display: flex !important;
                  }

                  .urlbar-input-box {
                    margin-left: 5px;
                  }

                  #urlbar:not([hover]) #page-action-buttons,
                  #urlbar:not([hover]) #tracking-protection-icon-container,
                  #urlbar:not([hover]) #identity-box {
                    transition: opacity 2s linear 2s, visibility 2s linear 0s;
                    visibility: collapse;
                    opacity: 0%;
                  }

                  #urlbar:hover #page-action-buttons,
                  #urlbar:hover #tracking-protection-icon-container,
                  #urlbar:hover #identity-box {
                    transition: opacity .5s linear .5s, visibility .5s linear 0s;
                    visibility: visible;
                    opacity: 100%;
                  }
        '';
        userContent = ''
          .TridactylStatusIndicator.TridactylModenormal { display: none !important; }
        '';
      };
    };
  };
}
