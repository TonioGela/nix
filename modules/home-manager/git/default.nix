{
  config,
  lib,
  pkgs,
  pkgsUnstable,
  ...
}:
let
  ghExe = lib.getExe pkgsUnstable.gh;
  glabExe = lib.getExe pkgsUnstable.glab;
  gitExe = lib.getExe config.programs.git.package;
  deltaExe = lib.getExe config.programs.delta.package;
  gitIgnoreLines = builtins.filter (x: x != "" && x != [ ]) (
    builtins.split "\n" (builtins.readFile ./gitignore_global)
  );
in
{
  options = {

    git.username = pkgs.lib.mkOption {
      type = pkgs.lib.types.str;
    };

    git.email = pkgs.lib.mkOption {
      type = pkgs.lib.types.str;
    };

    git.signingKey = pkgs.lib.mkOption {
      type = pkgs.lib.types.str;
      default = "";
      description = ''
        After you generate a key with `gpg --full-generate-key`
        you can see it's id with `gpg --list-secret-keys --keyid-format=long`.
        To see the public one for github/lab use `gpg --armor --export <ID>`
      '';
    };

    git.maintainedRepos = pkgs.lib.mkOption {
      type = pkgs.lib.types.listOf pkgs.lib.types.str;
      default = [ ];
    };
  };

  config = {
    # `echo "test" | gpg2 --clearsign` will check if gpg2 works
    # `gpgconf --kill gpg-agent` reboots the agent if necessary
    programs.git = {
      enable = true;
      package = pkgs.gitFull;
      lfs.enable = true;
      settings.user.name = config.git.username;
      settings.user.email = config.git.email;
      signing = {
        signByDefault = config.git.signingKey != "";
        key = config.git.signingKey;
      };

      settings.alias = {
        co = "checkout";
        diffw = "diff --ignore-space-change";
        rbi = "rebase --interactive";
        fpush = "push --force-with-lease";
        log-full = "log --pretty=fuller --show-signature --no-abbrev";
        cleanup = "!${gitExe} fetch --all --prune --prune-tags --quiet && (${gitExe} branch -v | rg --fixed-strings '[gone]' || exit 0)";
        wip = "!${gitExe} add --all . && ${gitExe} commit -m 'wip' && ${gitExe} push -o ci.skip";
        branches = "!${gitExe} for-each-ref --format='%(authorname)~%(refname)' --sort authorname | grep -v prefetch | cut -d'~' -f1 | sort | uniq -c | sort -nr";
        branches-of = "!${gitExe} for-each-ref --format='%(authorname) %(refname)' --sort authorname | grep -v prefetch | grep";
      };

      ignores = gitIgnoreLines;

      maintenance = {
        enable = true;
        repositories = config.git.maintainedRepos;
      };

      settings = {
        absorb.oneFixupPerCommit = true;
        blame.ignoreRevsFile = ".git-blame-ignore-revs";
        branch = {
          autosetuprebase = "always";
          sort = "-committerdate";
        };
        column.ui = "auto";
        commit.verbose = true;
        core.editor = "nvim";
        credential = {
          helper = "";
          "https://github.com".helper = "!${ghExe} auth git-credential";
          "https://gitlab.com".helper = "!${glabExe} auth git-credential";
        };
        diff = {
          algorithm = "histogram";
          colorMoved = "default";
        };
        fetch = {
          prune = true;
          prunetags = true;
          writeCommitGraph = true;
        };
        format.pretty = "oneline";
        help.autocorrect = "prompt";
        init.defaultBranch = "main";
        log = {
          abbrevCommit = true;
          date = "iso";
        };
        merge.conflictStyle = "zdiff3";
        pager = {
          diff = deltaExe;
          log = deltaExe;
          reflog = deltaExe;
          show = deltaExe;
        };
        pull = {
          ff = "only";
          rebase = true;
        };
        push = {
          autoSetupRemote = true;
          followtags = true;
        };
        rebase = {
          autosquash = true;
          autostash = true;
          missingCommitsCheck = "error";
          updateRefs = true;
        };
        rerere = {
          autoUpdate = true;
          enabled = true;
        };
        sequence.editor = "nvim";
        transport.bundleURI = false;
        tag.sort = "taggerdate";
        url = {
          "https://github.com/".insteadOf = "git@github.com:";
          "https://gitlab.com/".insteadOf = "git@gitlab.com:";
        };
        maintenance = {
          gc = {
            enabled = true;
            schedule = "hourly";
          };
          incremental-repack = {
            enabled = true;
            schedule = "hourly";
          };
          commit-graph = {
            enabled = true;
            schedule = "hourly";
          };
          prefetch = {
            enabled = true;
            schedule = "hourly";
          };
          loose-objects = {
            enabled = true;
            schedule = "hourly";
          };
        };
      };
    };

    programs.delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        navigate = true;
        hyperlinks = true;
        hyperlinks-file-link-format = "vscodium://file/{path}:{line}";
        features = "decorations unobtrusive-line-numbers";
        whitespace-error-style = "22 reverse";
        syntax-theme = "Nord";
        decorations = {
          commit-decoration-style = "bold yellow box ul";
          file-style = "bold yellow ul";
          file-decoration-style = "bold ul auto";
          hunk-header-style = "syntax";
          hunk-header-decoration-style = "white box";
        };
        unobtrusive-line-numbers = {
          line-numbers = true;
          line-numbers-minus-style = "red";
          line-numbers-zero-style = "syntax";
          line-numbers-plus-style = "green";
          line-numbers-left-format = "{nm:4}┊";
          line-numbers-right-format = "{np:4}│";
          line-numbers-left-style = "blue";
          line-numbers-right-style = "blue";
        };
      };
    };

    home.packages = [
      pkgsUnstable.gh
      pkgs.git-standup
      pkgs.git-absorb
      pkgs.git-crypt
      (pkgs.writeShellScriptBin "git-rebase-since" ''
        ${gitExe} rebase --interactive $(git merge-base HEAD $1)
      '')
      (pkgs.writeShellScriptBin "git-log-since" ''
        ${gitExe} log $(git merge-base HEAD $1)..
      '')
      (pkgs.writeShellScriptBin "git-rebase-on" ''
        if [ -z "''${1}" ];
        then
          echo "Usage: git rebase-on <branch-name>"
          exit 1
        else
          current=$(${gitExe} branch --show-current)
          ${gitExe} switch "''${1}"
          ${gitExe} pull
          ${gitExe} switch "''${current}"
          ${gitExe} rebase "''${1}"
        fi
      '')
      (pkgs.writeShellScriptBin "git-recent" ''
        branch=$(${gitExe} branch | tr -d '* ' | fzf --height=10 --no-input)
        if [ -n "$branch" ]; then
          ${gitExe} switch "$branch"
        else
          echo "No branch selected"
        fi
      '')
    ];
  };
}
