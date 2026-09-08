{ config, pkgs, ... }:
let
  todoDir = "${config.home.homeDirectory}/.todo";

  todoConfig = pkgs.writeText "todo-config" ''
    export TODO_DIR="${todoDir}"
    export TODO_FILE="$TODO_DIR/todo.txt"
    export DONE_FILE="$TODO_DIR/done.txt"
    export REPORT_FILE=/dev/null
    export TODOTXT_DEFAULT_ACTION=ls
    export TODOTXT_AUTO_ARCHIVE=1
    export TODOTXT_VERBOSE=0
  '';

  todo = pkgs.writeShellApplication {
    name = "todo";
    runtimeInputs = [
      pkgs.todo-txt-cli
      pkgs.git
    ];
    text = ''
      cd "${todoDir}"
      git pull --rebase --quiet || echo "todo: pull failed, working offline" >&2

      status=0
      env TODOTXT_CFG_FILE=${todoConfig} todo.sh "$@" || status=$?

      git add --all
      if ! git diff --cached --quiet; then
        git commit --quiet --message "todo: $*"
        git push --quiet || echo "todo: push failed, commit is local" >&2
      fi

      exit "$status"
    '';
  };
in
{
  home.packages = [ todo ];
}
