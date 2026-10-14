{ pkgs, lib, config, ... }:
let
  cfg = config.eureka.ollama;

  # Brave is Chromium-based, so omp's browser/Eval tooling and ompweb can drive
  # it directly. Pointing PUPPETEER_EXECUTABLE_PATH at it stops omp from
  # downloading its own Chromium the first time a browser is needed.
  #
  # `pkgs.brave` is a Linux-only package (filtered out on darwin), so on macOS
  # point at the standard Brave cask install location instead.
  braveBin =
    if pkgs.stdenv.isDarwin then
      "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser"
    else
      "${pkgs.brave}/bin/brave";

  ompBin = "${config.programs.omp.package}/bin/omp";

  # ompweb with a "Kasane" theme (the default) from this host's palette.
  ompweb = pkgs.ompweb.override { kasaneColors = config.programs.kasane.colors; };

  # omp selector for the host's local model. `:low` caps thinking: on the CPU
  # hosts every generated token costs ~0.12s, so unbounded reasoning dominates.
  localModel = "ollama/${cfg.model}:low";

  # Environment shared by the ompweb service on both platforms. node 24+ is
  # required by ompweb's engines field; omp is pinned so the service does not
  # depend on it being on PATH. OLLAMA_CONTEXT_LENGTH is passed through so the
  # omp process ompweb spawns budgets context the same as the TUI. Update
  # checks are off because omp and ompweb are Nix-managed and can't self-update.
  ompwebEnv = {
    OMP_WEB_OMP_BIN = ompBin;
    OMP_WEB_DISABLE_AUTOUPDATE = "1";
    PUPPETEER_EXECUTABLE_PATH = braveBin;
    BROWSER = braveBin;
    inherit (cfg.environment) OLLAMA_CONTEXT_LENGTH;
  };

  # Every omp session ompweb spawns inherits this PATH, so its bash tool needs
  # the same tools as a login shell (git, curl, nix, …), not just node.
  ompwebPath = lib.concatStringsSep ":" ([
    (lib.makeBinPath [ pkgs.nodejs_24 ])
    "${config.home.profileDirectory}/bin"
  ] ++ (if pkgs.stdenv.isDarwin then [
    "/run/current-system/sw/bin"
    "/nix/var/nix/profiles/default/bin"
    "/opt/homebrew/bin"
    "/usr/local/bin"
    "/usr/bin"
    "/bin"
    "/usr/sbin"
    "/sbin"
  ] else [
    "/run/wrappers/bin"
    "/run/current-system/sw/bin"
  ]));
in
{
  imports = [ ./omp-kasane.nix ];

  # Per-host local model setup. Read by the NixOS Ollama service too
  # (users/eureka/nixos/configuration.nix), so a host sets it once here.
  options.eureka.ollama = {
    model = lib.mkOption {
      type = lib.types.str;
      example = "gpt-oss:20b";
      description = ''
        Ollama tag this host serves for omp: the offline / usage-limit
        fallback for every chat role, and the `smol` model when
        `localSubagents` is set. Size it to the host's VRAM or RAM.
      '';
    };

    extraModels = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        Additional Ollama tags to keep pulled on this host. On NixOS
        `syncModels` deletes anything not in `model` + `extraModels`.
      '';
    };

    localSubagents = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Route omp's `smol` role (scout/sonic subagents, commit messages,
        session titles) to the local model. Only worth it on a dGPU: CPU
        prefill runs ~35 tok/s, so a single agent turn takes minutes.
      '';
    };

    quantizeKvCache = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Flash attention + q8_0 KV cache: halves context memory, which is what
        fits an 8B model and 32K context in a 16GB Mac's GPU budget. GPU
        hosts only: on CPU it cut qwen3:30b prefill from ~36 to ~10 tok/s.
      '';
    };

    environment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      readOnly = true;
      default = {
        # The default (~4K, chosen from VRAM) can't hold a coding agent's
        # system prompt plus tool schemas, so tools get truncated out and the
        # model never calls them. Read under the same name by the Ollama
        # server (runtime num_ctx) and by omp (its context budgeting), so it
        # is exported to both.
        OLLAMA_CONTEXT_LENGTH = "32768";
        # Subagent bursts are often >5m apart; reloading costs ~20s on CPU.
        OLLAMA_KEEP_ALIVE = "30m";
      } // lib.optionalAttrs cfg.quantizeKvCache {
        OLLAMA_FLASH_ATTENTION = "1";
        OLLAMA_KV_CACHE_TYPE = "q8_0";
      };
      description = "Ollama server environment, derived from the options above.";
    };
  };

  config = {
    # omp (oh-my-pi) coding agent — the TUI.
    #   • Claude: run `omp` once and `/login` to authenticate Anthropic.
    #   • Local models: served by Ollama at http://127.0.0.1:11434 and
    #     auto-discovered as `ollama/<tag>`.
    # Switch between them at runtime with `/model`.
    #
    # The module *copies* these settings over ~/.omp/agent/config.yml on every
    # switch, so changes made in the TUI or ompweb last until the next rebuild;
    # make them permanent here.
    programs.omp = {
      enable = true;
      settings = {
        setupVersion = 2;
        startup = {
          quiet = true;
          checkUpdate = false;
        };
        symbolPreset = "nerd";
        composer.shape = "rule";
        # Dark slot: the kasane theme, set in ./omp-kasane.nix.
        theme.light = "light";
        statusLine = {
          transparent = false;
          separator = "powerline";
        };
        display.subagentLivePreview = false;

        modelRoles = {
          default = "anthropic/claude-opus-5-5";
        } // lib.optionalAttrs cfg.localSubagents {
          smol = localModel;
        };

        # Any provider error on a chat role (offline, Anthropic down, usage
        # limit) switches to the local model on the first failure; the
        # session returns to Claude once its cooldown expires. Roles without
        # their own chain (smol, task, slow, …) inherit `default`.
        retry.fallbackChains.default = [ localModel ];

        # One GPU/CPU per host: queue local requests in omp instead of
        # letting parallel subagents pile up behind Ollama's single slot.
        providers.maxInFlightRequests.ollama = 1;
      };
    };

    # Ollama on darwin. On NixOS the system service serves it instead (a user
    # service would lose the race for :11434 and crash-loop).
    services.ollama = lib.mkIf pkgs.stdenv.isDarwin {
      enable = true;
      environmentVariables = cfg.environment;
    };

    # The home-manager module has no `loadModels`; pull this host's models at
    # login. Relaunched until it succeeds, since Ollama may not be up yet.
    launchd.agents.ollama-pull = lib.mkIf pkgs.stdenv.isDarwin {
      enable = true;
      config = {
        ProgramArguments = [
          "${pkgs.bash}/bin/bash"
          "-c"
          (lib.concatMapStringsSep " && "
            (m: "${lib.getExe config.services.ollama.package} pull ${lib.escapeShellArg m}")
            ([ cfg.model ] ++ cfg.extraModels))
        ];
        EnvironmentVariables.OLLAMA_HOST = "127.0.0.1:11434";
        RunAtLoad = true;
        KeepAlive.SuccessfulExit = false;
        ThrottleInterval = 60;
        ProcessType = "Background";
      };
    };

    # ompweb CLI + its Node runtime.
    home.packages = [ ompweb pkgs.nodejs_24 ];

    home.sessionVariables = {
      # Use Brave instead of downloading Chromium for omp's browser tooling,
      # and as the browser `ompweb` (run manually) opens.
      PUPPETEER_EXECUTABLE_PATH = braveBin;
      BROWSER = braveBin;
      # Match omp's context budgeting to the Ollama server's num_ctx.
      inherit (cfg.environment) OLLAMA_CONTEXT_LENGTH;
    };

    # ompweb — web UI for omp at http://127.0.0.1:30177. Starts at login,
    # restarts on crash; open Brave to the URL yourself (--no-open: a background
    # service must not spawn a browser). systemd on Linux, launchd on darwin.
    # Model roles, fallback chains and agents all come from omp's config above.
    systemd.user.services.ompweb = lib.mkIf pkgs.stdenv.isLinux {
      Unit = {
        Description = "ompweb — web UI for the omp coding agent";
        After = [ "network.target" ];
      };
      Service = {
        ExecStart = "${ompweb}/bin/ompweb --no-open";
        Restart = "on-failure";
        RestartSec = 5;
        Environment =
          [ "PATH=${ompwebPath}" ]
          ++ lib.mapAttrsToList (n: v: "${n}=${v}") ompwebEnv;
      };
      Install.WantedBy = [ "default.target" ];
    };

    launchd.agents.ompweb = lib.mkIf pkgs.stdenv.isDarwin {
      enable = true;
      config = {
        ProgramArguments = [ "${ompweb}/bin/ompweb" "--no-open" ];
        EnvironmentVariables = ompwebEnv // {
          PATH = ompwebPath;
        };
        RunAtLoad = true;
        KeepAlive = {
          Crashed = true;
          SuccessfulExit = false;
        };
        ProcessType = "Background";
      };
    };
  };
}
