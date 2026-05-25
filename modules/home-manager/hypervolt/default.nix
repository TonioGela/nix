{
  pkgs,
  pkgsUnstable,
  ...
}:
{
  # To use this config effectively rememeber to:
  # - Import the old or create a new gpg key to sign commits and set it both in glab and here
  # - Import the old or create a new SSH key to put in the keys repo
  # - Import .sbt/.credentials # TODO Actually this can be made a template with sops-nix
  # - On nixos set services.pcscd.enable = true; and services.udev.packages = [ pkgs.yubikey-personalization ];

  imports = [ (import (import ./npins).hypervolt-modules) ];

  home.file.".aws/config".source = ./aws_config;

  programs.git.includes = [
    {
      condition = "gitdir:~/work/";
      contents = {
        settings.user.name = "Antonio Gelameris";
        settings.user.email = "antonio.gelameris@hypervolt.co.uk";
        signing = {
          signByDefault = true;
          key = "25901F702B062B05";
        };
      };
    }
  ];

  zsh = {
    extraSessionVariables =
      let
        token = "$(${pkgs.lib.getExe pkgs.yq} --exit-status --raw-output '.hosts[\"gitlab.com\"].token' ~/.config/glab-cli/config.yml)";
      in
      {
        TF_TOKEN_gitlab_com = token;
        GITLAB_TOKEN = token;
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
    pkgs.aws-vault
    pkgs.awscli2
    pkgsUnstable.glab
    pkgs.jwt-cli
    pkgs.pgcli
    pkgsUnstable.slack
    pkgs.terraform
    pkgs.vault
    pkgs.websocat
    pkgs.yq
    pkgs.yubikey-manager
  ];

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
