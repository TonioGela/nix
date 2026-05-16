{
  pkgs,
  pkgsUnstable,
  config,
  lib,
  ...
}:
let
  extensions = with pkgs.vscode-extensions; [
    aaron-bond.better-comments
    usernamehw.errorlens
    hashicorp.terraform
    oderwat.indent-rainbow
    marp-team.marp-vscode
    jnoortheen.nix-ide
    arcticicestudio.nord-visual-studio-code
    vscode-icons-team.vscode-icons
    mechatroner.rainbow-csv
    rust-lang.rust-analyzer
  ];

  marketPlaceExtensions = pkgs.vscode-utils.extensionsFromVscodeMarketplace [
    {
      name = "scala";
      publisher = "scala-lang";
      version = "0.5.9";
      sha256 = "sha256-zgCqKwnP7Fm655FPUkD5GL+/goaplST8507X890Tnhc=";
    }
    {
      name = "metals";
      publisher = "scalameta";
      version = "1.65.3";
      sha256 = "sha256-Asxj9c+tFO6ziy/nbAN7z/SQjKJdUXufjVD3GnNAaJo=";
    }
  ];
in
{

  xdg.desktopEntries.codium = lib.mkIf pkgs.stdenv.isLinux {
    name = "VSCodium";
    noDisplay = true;
  };

  home.packages = [
    pkgsUnstable.nixd
    pkgsUnstable.nixfmt
  ];

  home.sessionVariables = {
    NIXD_PATH = lib.getExe pkgsUnstable.nixd;
  };

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium.override {
      commandLineArgs = [ "--ozone-platform=wayland" ];
    };
    mutableExtensionsDir = false;
    profiles.default = {
      enableExtensionUpdateCheck = true;
      enableUpdateCheck = true;
      extensions = extensions ++ marketPlaceExtensions;
      userTasks = {
        version = "2.0.0";
        tasks = [
          {
            type = "shell";
            label = "Hello task";
            command = "echo hello";
          }
        ];
      };
      userSettings = config.lib.file.mkOutOfStoreSymlink ./vscodium.json;
      keybindings = [
        {
          "key" = "shift+cmd+=";
          "command" = "editor.action.fontZoomIn";
        }
        {
          "key" = "shift+cmd+=";
          "command" = "-workbench.action.zoomIn";
        }
        {
          "key" = "shift+cmd+-";
          "command" = "editor.action.fontZoomOut";
        }
        {
          "key" = "shift+cmd+-";
          "command" = "-workbench.action.zoomOut";
        }
        {
          "key" = "cmd+s";
          "command" = "workbench.action.files.saveAll";
        }
        {
          "key" = "cmd+s";
          "command" = "-workbench.action.files.save";
        }
        {
          "key" = "cmd+;";
          "command" = "editor.action.triggerParameterHints";
          "when" = "editorHasSignatureHelpProvider && editorTextFocus";
        }
        {
          "key" = "cmd+r";
          "command" = "editor.action.startFindReplaceAction";
          "when" = "editorFocus || editorIsOpen";
        }
        {
          "key" = "ctrl+=";
          "command" = "workbench.action.navigateForward";
        }
        {
          "key" = "ctrl+i";
          "command" = "metals.toggle-implicit-conversions-and-classes";
        }
        {
          "key" = "ctrl+alt+i";
          "command" = "metals.toggle-implicit-parameters";
        }
        {
          "key" = "ctrl+alt+cmd+i";
          "command" = "metals.toggle-show-inferred-type";
        }
        {
          "key" = "ctrl+\\";
          "command" = "workbench.action.terminal.toggleTerminal";
        }
        {
          "key" = "shift+cmd+/";
          "command" = "editor.action.blockComment";
          "when" = "editorTextFocus && !editorReadonly";
        }
        {
          "key" = "cmd+e";
          "command" = "workbench.view.explorer";
        }
        {
          "key" = "cmd+e";
          "command" = "-actions.findWithSelection";
        }
        {
          "key" = "cmd+b";
          "command" = "workbench.action.toggleActivityBarVisibility";
        }
        {
          "key" = "cmd+b";
          "command" = "-workbench.action.toggleSidebarVisibility";
        }
        {
          "key" = "shift+cmd+b";
          "command" = "workbench.action.toggleSidebarVisibility";
        }
        {
          "key" = "shift+cmd+b";
          "command" = "-workbench.action.tasks.build";
        }
      ];
      globalSnippets = {
        fixme = {
          body = [
            "$LINE_COMMENT FIXME: $0"
          ];
          description = "Insert a FIXME remark";
          prefix = [
            "fixme"
          ];
        };
      };
      languageSnippets = {
        # haskell = {
        #   fixme = {
        #     body = [
        #       "$LINE_COMMENT FIXME: $0"
        #     ];
        #     description = "Insert a FIXME remark";
        #     prefix = [
        #       "fixme"
        #     ];
        #   };
        # };
      };
    };
  };
}
