{
  pkgs,
  pkgsUnstable,
  config,
  lib,
  ...
}:
{

  options = {
    vscodium.profileFile = lib.mkOption {
      type = lib.types.str;
      description = "The suffix of the settings.json file to symlink";
    };
  };

  config = {

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

    programs.vscodium = {
      enable = true;
      package = pkgs.vscodium.override {
        commandLineArgs = [ "--ozone-platform=wayland" ];
      };
      mutableExtensionsDir = false;
      profiles.default = {
        enableExtensionUpdateCheck = true;
        enableUpdateCheck = true;
        extensions = with pkgs; [
          vscode-marketplace.aaron-bond.better-comments
          vscode-marketplace.usernamehw.errorlens
          vscode-marketplace.hashicorp.terraform
          vscode-marketplace.oderwat.indent-rainbow
          vscode-marketplace.marp-team.marp-vscode
          vscode-marketplace.jnoortheen.nix-ide
          vscode-marketplace.arcticicestudio.nord-visual-studio-code
          vscode-marketplace.vscode-icons-team.vscode-icons
          vscode-marketplace.mechatroner.rainbow-csv
          vscode-marketplace.rust-lang.rust-analyzer
          vscode-marketplace.mkhl.direnv
          vscode-marketplace.scalameta.metals
          vscode-marketplace.scala-lang.scala
          open-vsx.pcode-pl.hide-files-toggle
        ];
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
        userSettings = config.lib.file.mkOutOfStoreSymlink ./vscodium_${config.vscodium.profileFile}.json;
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
  };
}
