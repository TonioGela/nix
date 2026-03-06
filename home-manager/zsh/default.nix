{
  lib,
  pkgs,
  config,
  ...
}:
let
  zoxide = lib.getExe pkgs.zoxide;
  dotDir = ".config/zsh";
  absoluteDotDir = "${config.home.homeDirectory}/${dotDir}";
  opts = [
    "combining_chars"
    "no_beep"
    "no_prompt_bang"
    "no_prompt_subst"
    "prompt_percent"
    "menu_complete"
    "auto_list"
    "always_to_end"
    "list_packed"
    "hist_verify"
    "extended_glob"
  ];

  prompt_init = ''
    # Clone if necessary and source gitstatus
    if [[ ! -e ${absoluteDotDir}/gitstatus ]]; then
      git clone --depth=1 https://github.com/romkatv/gitstatus.git ${absoluteDotDir}/gitstatus
    fi

    source ${absoluteDotDir}/gitstatus/gitstatus.plugin.zsh
    gitstatus_stop 'MY_PROMPT' && gitstatus_start 'MY_PROMPT'

    # zcompile if necessary, autoload the prompt and add it to precmd_functions
    [[ ${absoluteDotDir}/create_prompt.zwc -nt ${absoluteDotDir}/create_prompt ]] || zcompile -M ${absoluteDotDir}/create_prompt ${absoluteDotDir}/create_prompt.zwc
    autoload -Uz create_prompt
    precmd_functions+=(create_prompt)'';

  comp_settings = ''
    [[ ${absoluteDotDir}/zcompdump.zwc -nt ${absoluteDotDir}/zcompdump ]] || zcompile -R ${absoluteDotDir}/zcompdump ${absoluteDotDir}/zcompdump.zwc
    _comp_options+=(globdots) # Complete with hidden files too
    zstyle ':completion:*' menu select'';

  zoxide_init = ''
    [[ ${absoluteDotDir}/zoxide_init.zwc -nt ${absoluteDotDir}/zoxide_init ]] || zcompile -M ${absoluteDotDir}/zoxide_init ${absoluteDotDir}/zoxide_init.zwc
    autoload -Uz zoxide_init && zoxide_init'';

  custom_functions = ''
    function zat() {
      command zathura $@ &>/dev/null &|
    }

    function toChd() {
      chdman createcd --input "$1" --output "''${1%.*}.chd"
    }

    function 7z() {
       bsdtar --format 7zip -cf "''${1%.*}.7z" "$1"
    }

    function meteo() {
      local list_flag=0
      local positional_arg
      local options

      zparseopts -D -E l=list_flag
      positional_arg=$1

      [[ -n $list_flag ]] && options="FQ" || options="FQ0"

      curl "wttr.in/''${positional_arg:-Milan}?''$options"
    }

    function repl() {
      scala-cli repl --toolkit typelevel:default \
       --repl-init-script \
      "import cats.syntax.all.*, cats.*, cats.data.*, cats.effect.*, fs2.*, cats.effect.unsafe.implicits.global, scala.concurrent.duration.*"
    }

    function cat() {
      for i in "$@"
      do
        if [[ -d "$i" ]] then
          eza -l --group-directories-first -sname --git --icons "$i"
        elif [[ -f "$i" ]] then
          bat --plain "$i"
        fi
      done
    }

    function toLong() {
      printf '%d\n' "0x$1"
    }

    function toHex() {
      echo "''${(l:16::0:)''$(printf '%x\n' $1)}"
    }

    function codium-patch() {
      sudo chown -R $(whoami) ${pkgs.vscodium.outPath}
      sudo chmod -R u+w ${pkgs.vscodium.outPath}
    }
  '';
in
{
  home.file."${dotDir}/create_prompt".text = ''
    create_prompt() {
      local GIT_STATUS

      if gitstatus_query MY_PROMPT && [[ $VCS_STATUS_RESULT == ok-sync ]]; then
        GIT_STATUS=" ''${''${VCS_STATUS_LOCAL_BRANCH:-@''${VCS_STATUS_COMMIT}}//\%/%%}" # escape %
        (( VCS_STATUS_NUM_STAGED || VCS_STATUS_NUM_UNSTAGED || VCS_STATUS_NUM_UNTRACKED )) && GIT_STATUS+='*'
        (( VCS_STATUS_COMMITS_BEHIND || VCS_STATUS_COMMITS_AHEAD)) && GIT_STATUS+=" "
        (( VCS_STATUS_COMMITS_BEHIND )) && GIT_STATUS+="⇣"
        (( VCS_STATUS_COMMITS_AHEAD ))  && GIT_STATUS+="⇡"
      fi

      PROMPT="%F{blue}%~%F{red}''${GIT_STATUS} %B%F{%(?/green/red)}❯%f%b "
    }
  '';

  home.activation.zoxide = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${zoxide} init zsh > ${absoluteDotDir}/zoxide_init
  '';

  home.activation.restish = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${lib.getExe pkgs.restish} completion zsh > ${absoluteDotDir}/_restish
  '';

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
    silent = true;
    stdlib = ''
      if [ -f ./shell.nix ]; then use nix ; fi
      export TERM="xterm-256color"
    '';
    config = {
      disable_stdin = true;
      strict_env = true;
      hide_env_diff = true;
      log_format = "-";
      log_filter = "^$";
      warn_timeout = "2s";
    };
  };

  programs.zsh = {
    enable = true;
    autocd = false;
    cdpath = [ ];
    dotDir = absoluteDotDir;

    shellAliases = {
      tf = "terraform";
      hm = "codium ~/.config/home-manager";
      ls = "eza -l --group-directories-first -sname --git --icons";
      cp = "cp -i";
      mv = "mv -i";
      rm = "rm -i";
      flushdns = "sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder";
      off = "niri msg action quit && systemctl poweroff";
    };

    shellGlobalAliases = { };

    enableCompletion = true;
    completionInit = "autoload -Uz compinit && compinit -d ${absoluteDotDir}/zcompdump";
    zprof.enable = false;
    syntaxHighlighting.enable = false;

    # I do this manually
    historySubstringSearch.enable = false;

    autosuggestion.enable = false;
    history = {
      path = "${absoluteDotDir}/zsh_history";
      append = true;
      expireDuplicatesFirst = true;
      extended = true;
      ignoreAllDups = true;
      ignoreDups = true;
      saveNoDups = true;
      findNoDups = true;
      save = 100000000;
      size = 1000000000;
    };

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      LESSHISTFILE = "-";
      LANG = "en_GB.UTF-8";
      GPG_TTY = "''$(tty)";
      MANPAGER = "less -R --use-color -Dd+r -Du+b";
      BAT_THEME = "Nord";
      FZF_DEFAULT_OPTS = "--style minimal --border --reverse --highlight-line --margin=1,25%  --height=20%";
      NO_TEST_LOGS = "1";
      JAVA_OPTS = "-Xmx10G";
    };

    initContent = lib.mkMerge [
      (lib.mkOrder 500 ''
        if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
          . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
        fi

        disable log
        setopt ${builtins.concatStringsSep " " opts}

        fpath+=(${absoluteDotDir})

        ${prompt_init}'')
      (lib.mkOrder 550 comp_settings)
      (lib.mkOrder 1000 ''
        # Running `bindkey` shows all the bindings
        # Running `zle -al` shows all the existing widgets
        # Running `cat -v` outputs the written form of a key combination
        autoload -Uz history-search-end
        autoload -Uz edit-command-line
        zle -N history-beginning-search-backward-end history-search-end
        zle -N history-beginning-search-forward-end history-search-end
        zle -N edit-command-line
        bindkey "^[[A" history-beginning-search-backward-end
        bindkey "^[[B" history-beginning-search-forward-end
        bindkey "^[[1;9D" beginning-of-line
        bindkey "^[[1;9C" end-of-line
        bindkey "^[[1;2D" backward-word
        bindkey "^[[1;2C" forward-word
        bindkey "^[[1;3D" backward-word
        bindkey "^[[1;3C" forward-word
        bindkey "^[[1;10D" backward-word
        bindkey "^[[1;10C" forward-word
        bindkey "^E" edit-command-line
        bindkey "^[^?" vi-kill-eol
        bindkey "^U" vi-kill-line
      '')
      (lib.mkOrder 1500 ''
        ${zoxide_init}

        ${custom_functions}
      '')
    ];

    envExtra = ''
      setopt no_global_rcs
    '';
  };
}
