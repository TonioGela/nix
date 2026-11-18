{
  config,
  pkgs,
  lib,
  ...
}:
# Local LLM server for the office assistant: Ollama (native, Metal) + AnythingLLM in a colima container.
# Only the declarative part lives here. The few manual steps are in the chat, not in the repo.
let
  home = config.home.homeDirectory;
  logs = "${home}/Library/Logs";
  anythingDir = "${home}/anythingllm";
  binPath = lib.makeBinPath [
    pkgs.colima
    pkgs.docker-client
    pkgs.lima
  ];
  tsCli = "${pkgs.tailscale}/bin/tailscale --socket=${home}/Library/Application Support/tailscale/tailscaled.sock";
  # Runs at every login. Idempotent: waits for each piece (tailscale login, colima) and applies it.
  # Only the tailscale login itself and the Caddy password file are left by hand.
  setupScript = pkgs.writeShellScript "llm-setup" ''
    export PATH=${binPath}:/usr/bin:/bin:/usr/sbin:/sbin

    until ${tsCli} status --json 2>/dev/null | grep -q '"BackendState": "Running"'; do sleep 15; done
    ${tsCli} serve --bg --tcp=443 tcp://127.0.0.1:8443
    # SSH from the tailnet, needs Remote Login enabled once (see the sudo block)
    ${tsCli} serve --bg --tcp=22 tcp://127.0.0.1:22
    # On this tailscale version the tag is applied with `up`, not `set`. It needs tag:llm in the ACL,
    # without it the command fails and the next login retries. It must not block the rest.
    ${tsCli} up --hostname=llm --advertise-tags=tag:llm || true

    until docker info >/dev/null 2>&1; do sleep 15; done
    docker compose -f ${anythingDir}/compose.yaml up -d
  '';
in
{
  home.packages = [
    pkgs.ollama
    pkgs.colima
    pkgs.docker-client
    pkgs.docker-compose
    pkgs.tailscale
    pkgs.caddy
  ];

  # `docker compose` looks for the compose plugin in ~/.docker/cli-plugins
  home.file.".docker/cli-plugins/docker-compose".source = "${pkgs.docker-compose}/bin/docker-compose";

  # --- Tailscale from nixpkgs: tailscaled as a user agent, userspace networking (no root, no system extension).
  # Login once with `tailscale up`. `tailscale serve` works in this mode.
  launchd.agents.tailscaled = {
    enable = true;
    config = {
      ProgramArguments = [
        "${pkgs.tailscale}/bin/tailscaled"
        "--tun=userspace-networking"
        "--statedir=${home}/Library/Application Support/tailscale"
        "--socket=${home}/Library/Application Support/tailscale/tailscaled.sock"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "${logs}/tailscaled.log";
      StandardErrorPath = "${logs}/tailscaled.log";
    };
  };

  # --- Ollama: native on macOS so it gets Metal. Never in a container. ---
  launchd.agents.ollama = {
    enable = true;
    config = {
      ProgramArguments = [
        "${pkgs.ollama}/bin/ollama"
        "serve"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      EnvironmentVariables = {
        # Loopback only. If the AnythingLLM container cannot reach it
        OLLAMA_HOST = "127.0.0.1:11434";
        OLLAMA_KEEP_ALIVE = "-1"; # dedicated machine: keep the model warm
        OLLAMA_CONTEXT_LENGTH = "8192";
        OLLAMA_FLASH_ATTENTION = "1";
        OLLAMA_KV_CACHE_TYPE = "q8_0";
        OLLAMA_NUM_PARALLEL = "1";
        OLLAMA_MAX_LOADED_MODELS = "2"; # chat + embedder
      };
      StandardOutPath = "${logs}/ollama.log";
      StandardErrorPath = "${logs}/ollama.log";
    };
  };

  # --- colima: the Linux VM that runs the AnythingLLM container ---
  launchd.agents.colima = {
    enable = true;
    config = {
      ProgramArguments = [
        "${pkgs.colima}/bin/colima"
        "start"
        "--foreground"
        "--cpu"
        "2"
        "--memory"
        "2"
        "--disk"
        "20"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      EnvironmentVariables.PATH = "${binPath}:/usr/bin:/bin:/usr/sbin:/sbin";
      StandardOutPath = "${logs}/colima.log";
      StandardErrorPath = "${logs}/colima.log";
    };
  };

  launchd.agents.llm-setup = {
    enable = true;
    config = {
      ProgramArguments = [ "${setupScript}" ];
      RunAtLoad = true;
      StandardOutPath = "${logs}/llm-setup.log";
      StandardErrorPath = "${logs}/llm-setup.log";
    };
  };

  # --- Caddy: TLS for llm.toniogela.dev and the second login, in front of AnythingLLM ---
  # gilderien passes the TCP stream through to llm's tailnet port 443, which tailscale serve
  # forwards to 127.0.0.1:8443. TLS-ALPN-01 runs on that same 443, so no
  # DNS API token and no port 80 are needed. The hash file is not in the repo: it's created by hand.
  home.file.".config/caddy/Caddyfile".text = ''
    {
      https_port 8443
      auto_https disable_redirects
      servers {
        # gilderien sends a PROXY protocol header before the TLS bytes. Tailscale serve
        # forwards from localhost, so only accept it from there.
        listener_wrappers {
          proxy_protocol {
            allow 127.0.0.1/32
          }
          tls
        }
      }
    }

    llm.toniogela.dev {
      bind 127.0.0.1
      tls {
        issuer acme {
          disable_http_challenge
        }
      }
      basic_auth {
        llm {file.${home}/.config/caddy/llm-basic-auth}
      }
      reverse_proxy 127.0.0.1:3001
    }
  '';

  launchd.agents.caddy = {
    enable = true;
    config = {
      ProgramArguments = [
        "${pkgs.caddy}/bin/caddy"
        "run"
        "--config"
        "${home}/.config/caddy/Caddyfile"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "${logs}/caddy.log";
      StandardErrorPath = "${logs}/caddy.log";
    };
  };

  # --- AnythingLLM: only the compose file is declarative ---
  # Port 3001 is bound to localhost. Caddy (above) is the only way in.
  home.file."anythingllm/compose.yaml".text = ''
    services:
      anythingllm:
        image: mintplexlabs/anythingllm:1.11.2
        container_name: anythingllm
        restart: unless-stopped
        ports:
          - "127.0.0.1:3001:3001"
        cap_add: [ SYS_ADMIN ]
        environment:
          - STORAGE_DIR=/app/server/storage
          - DISABLE_TELEMETRY=true
          # Models and providers. Ollama runs on the host, reached from the colima VM as host.lima.internal.
          # Names from upstream AnythingLLM docs, not checked against this image: verify in the UI.
          - LLM_PROVIDER=ollama
          - OLLAMA_BASE_PATH=http://host.lima.internal:11434
          - OLLAMA_MODEL_PREF=gemma3:12b
          - OLLAMA_MODEL_TOKEN_LIMIT=8192
          - EMBEDDING_ENGINE=ollama
          - EMBEDDING_BASE_PATH=http://host.lima.internal:11434
          - EMBEDDING_MODEL_PREF=bge-m3
          - VECTOR_DB=lancedb
        volumes:
          - ${anythingDir}/storage:/app/server/storage
          - ${anythingDir}/storage/.env:/app/server/.env
  '';

  # Storage and .env are written by the app at runtime, so they must stay mutable.
  # Not in the nix store. A missing .env would be created as a directory by docker.
  home.activation.anythingllmStorage = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD mkdir -p ${anythingDir}/storage
    $DRY_RUN_CMD touch ${anythingDir}/storage/.env
  '';
}
