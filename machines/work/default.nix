{
  sources,
  modules,
  pkgs,
  pkgsUnstable,
  ...
}:
let
  pins = import ./npins;
  hypervolt-modules = import pins.hypervolt-modules;
  derivations = import ./derivations.nix { inherit sources; };
in
{
  imports = with modules.home-manager; [
    hypervolt-modules
    firefox
    git
    scala
    vscodium
    zathura
    darwin
    gpg
    kitty
    neovim
    nh-npins
    nix-index
    yabai-skhd
    yazi
    zsh
  ];

  home = {
    username = "toniogela";
    homeDirectory = "/Users/toniogela";
  };

  programs.nh = {
    nhFile = "/Users/toniogela/.config/home-manager/configuration.nix";
    nhAttrPath = "work";
  };

  home.file.".aws/config".source = ./aws_config;
  home.file.".hushlogin".text = "";

  darwin.masAppIds = [
    "1352778147" # Bitwarden
    "1503136033" # Service Station
  ];

  git = {
    username = "Antonio Gelameris";
    email = "antonio.gelameris@hypervolt.co.uk";
    signingKey = "25901F702B062B05";
    maintainedRepos = [
      "/Users/toniogela/work/athena"
      "/Users/toniogela/work/hypervolt-backend"
    ];
  };

  kitty = {
    fontSize = "14.0";
    extraConfig = ''
      map cmd+c                 copy_to_clipboard
      map cmd+v                 paste_from_clipboard
      map cmd+w                 close_os_window
      macos_quit_when_last_window_closed yes
    '';
  };

  zsh = {
    extraEnv = "eval `/usr/libexec/path_helper -s`";
    extraSessionVariables = {
      TF_TOKEN_gitlab_com = "$(${pkgs.lib.getExe pkgs.yq} --exit-status --raw-output '.hosts[\"gitlab.com\"].token' ~/.config/glab-cli/config.yml)";
    };
    extraAliases = {
      tf = "terraform";
      flushdns = "sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder";
    };
    extraFunctions = ''
      function toLong() {
        printf '%d\n' "0x$1"
      }

      function toHex() {
        echo "''${(l:16::0:)''$(printf '%x\n' $1)}"
      }
    '';
  };

  home.packages = [
    pkgs.appcleaner
    pkgs.aws-vault
    pkgs.awscli2
    pkgs.claude-code
    pkgs.defaultbrowser
    pkgsUnstable.glab
    pkgs.jwt-cli
    pkgs.nerd-fonts.sauce-code-pro
    pkgs.pgcli
    pkgsUnstable.slack
    pkgs.terraform
    pkgs.vault
    pkgs.websocat
    pkgs.wireshark
    pkgs.yq
    pkgs.yubikey-manager
  ]
  ++ [
    derivations.keeping-you-awake
    derivations.qlmarkdown
    derivations.source-code-syntax-highlight
    derivations.ice-bar
  ];

  launchd.agents.glabAuthRefresh = {
    enable = false;
    config = {
      Label = "dev.toniogela.glabAuthRefresh";
      ProgramArguments = [
        "${pkgs.lib.getExe pkgsUnstable.glab}"
        "auth"
        "status"
      ];
      StartInterval = 1800;
      LowPriorityIO = true;
      LowPriorityBackgroundIO = true;
      ProcessType = "Background";
      RunAtLoad = true;
      KeepAlive = false;
      StandardOutPath = "/tmp/glabAuthRefresh.log";
      StandardErrorPath = "/tmp/glabAuthRefresh.err";
      WatchPaths = [
        "/Users/toniogela/work/hypervolt-backend/.git"
        "/Users/toniogela/work/athena/.git"
      ];
    };
  };

  firefox.additionalBookmarks = [
    {
      name = "Hypervolt";
      bookmarks = [
        {
          name = "Jira";
          url = "https://hypervolt.atlassian.net/jira/software/c/projects/CLOUD/boards/2?assignee=712020%3A3021ae5d-2ced-47ca-ae2c-eb4cbebc861e";
        }
        {
          name = "Watson";
          url = "https://w4tson.hypervolt.co.uk";
        }
        {
          name = "Grafana-Staging";
          url = "https://grafana.staging.hypervolt.dev/";
        }
        {
          name = "Graphana-Prod";
          url = "https://grafana.prod.hypervolt.dev/";
        }
        {
          name = "Keycloak-Staging";
          url = "https://kc.staging.hypervolt.co.uk/admin/master/console/";
        }
        {
          name = "Keycloak-Prod";
          url = "https://kc.prod.hypervolt.co.uk/admin/master/console";
        }
        {
          name = "Hypervolt API";
          url = "https://api.hypervolt.co.uk/docs/index.html";
        }
        {
          name = "Athena API Staging";
          url = "https://athena.staging.hypervolt.dev/docs/";
        }
        {
          name = "Athena API Prod";
          url = "https://athena.prod.hypervolt.dev/docs/";
        }
        {
          name = "On-duty Rotation";
          url = "https://docs.google.com/spreadsheets/d/1gyPrkOAPERQTtinOeQa6D-Cvnt10LYlq-aeiOtqc_yk";
        }
        {
          name = "Confluence";
          url = "https://hypervolt.atlassian.net/wiki";
        }
        {
          name = "Chargers";
          url = "https://hypervolt.atlassian.net/wiki/spaces/ENG/pages/881950721/Engineering+Cloud+Chargers";
        }
        {
          name = "Repos";
          bookmarks = [
            {
              name = "Dashboard";
              url = "https://dashboard.eng.hypervolt.dev";
            }
            {
              name = "Repo: Backend";
              url = "https://gitlab.com/hypervolt/hypervolt-backend";
            }
            {
              name = "Repo: Libs";
              url = "https://gitlab.com/hypervolt/cloud/hypervolt-libs";
            }
            {
              name = "Repo: Athena";
              url = "https://gitlab.com/hypervolt/checkout/athena";
            }
            {
              name = "Repo: RFCs";
              url = "https://gitlab.com/hypervolt/cloud/backend-rfcs/-/merge_requests";
            }
          ];
        }
      ];
    }
  ];
}
