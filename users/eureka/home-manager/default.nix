{ pkgs, lib, config, osConfig ? { }, ... }:
let
  inherit (pkgs) stdenv;

  filterByPlatform = ps:
    let
      inherit (pkgs) hostPlatform;
      inherit (lib.meta) availableOn;
    in
    builtins.filter (p: availableOn hostPlatform p) ps;

  nixosOllamaModels = (osConfig.services.ollama or { }).loadModels or [ ];
  ollamaModels = lib.listToAttrs (map (m: lib.nameValuePair m { name = m; }) nixosOllamaModels);

  dotfiles = "${config.home.homeDirectory}/.config/dotfiles";
  opencodeDir = "${dotfiles}/users/eureka/home-manager/opencode";
  agentsDir = "${opencodeDir}/agents";

  litellmModels = {
    "claude-sonnet-proxy" = { name = "Claude Sonnet (proxy)"; };
    "claude-opus-proxy" = { name = "Claude Opus (proxy)"; };
    "local-fallback" = { name = "Local Fallback (qwen2.5-coder:14b)"; };
  };
in
{
  # Home Manager needs a bit of information about you and the paths it should manage.
  home.username = "eureka";
  home.homeDirectory = lib.mkDefault
    (if pkgs.stdenv.isDarwin then
      "/Users/eureka"
    else
      "/home/eureka");

  home.packages = filterByPlatform (with pkgs; [
    home-manager
    brave
    kitty
    kitty-themes
    # shell
    zsh
    oh-my-zsh
    pfetch
    fastfetch
    # code
    git
    helix
    docker
    pkgs.llm-agents.claude-code
    pkgs.llm-agents.oh-my-opencode
    # studio
    ffmpeg
    gphoto2
    obsidian
    obs-studio
    spotify
    zoom-us
  ]) ++ lib.optionals stdenv.isLinux (with pkgs; [
    wl-clipboard
  ]);

  stylix.targets.kitty = {
    # Prefer to manually set kitty theme
    enable = false;
    colors.enable = false;
  };
  programs.kitty = {
    enable = true;
    shellIntegration = {
      mode = "no-cursor";
      enableZshIntegration = true;
    };
    settings = {
      # The window padding (in pts) (blank area between the text and the window border).
      # A single value sets all four sides. Two values set the vertical and horizontal sides.
      # Three values set top, horizontal and bottom. Four values set top, right, bottom and left.
      window_padding_width = "8 0 8 8"; # extra padding for oh-my-zsh dst theme
      hide_window_decorations = true;
      cursor_shape = "block";
    };
  };
  programs.helix = {
    enable = true;
    defaultEditor = true;
    settings = {
      editor = {
        cursor-shape = {
          insert = "underline";
          normal = "block";
          select = "block";
        };
        statusline = {
          mode = {
            insert = "INSERT";
            normal = "NORMAL";
            select = "SELECT";
          };
        };
        indent-guides = {
          render = true;
          character = "╎";
          skip-levels = 1;
        };
        lsp = {
          display-messages = true;
          display-inlay-hints = true;
        };
      };
    };
    languages = {
      language-server.buf = {
        command = "${pkgs.buf}/bin/buf";
        args = [ "beta" "lsp" ];
      };
      formatter.ocaml = {
        command = "ocamlformat";
        args = [ "-" "--impl" ];
      };
      language = [
        {
          name = "protobuf";
          auto-format = true;
          language-servers = [ "buf" ];
        }
        {
          name = "ocaml";
          auto-format = true;
        }
      ];
    };
  };

  # zsh & oh-my-zsh configurations
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "eureka";
      custom = "${./zsh/custom}";
    };
  };
  programs.git = {
    enable = true;
    settings.user = {
      name = "eureka-cpu";
      email = "github.eureka@gmail.com";
    };
  };
  systemd.user.services.litellm-proxy = {
    Unit = {
      Description = "LiteLLM proxy (Anthropic -> local fallback)";
      After = [ "network.target" ];
    };
    Service = {
      ExecStart = "${lib.getExe pkgs.litellm} --config %h/.config/litellm/config.yaml --port 4000";
      Restart = "on-failure";
      RestartSec = 5;
      # Optional: populate ANTHROPIC_API_KEY=... here to enable Anthropic models.
      # If absent the proxy still starts and routes to the local fallback.
      EnvironmentFile = "-${config.home.homeDirectory}/.config/litellm/secrets";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  systemd.user.services.eureka-calendar-fetch = {
    Unit = {
      Description = "Fetch upcoming calendar events";
    };
    Service = {
      Type = "oneshot";
      ExecStart = ''
        ${pkgs.bash}/bin/bash -c '${pkgs.gcalcli}/bin/gcalcli agenda now "now + 24 hours" --nocolor --details url --tsv > %h/.cache/eureka-prompt/events.tsv.tmp && mv %h/.cache/eureka-prompt/events.tsv.tmp %h/.cache/eureka-prompt/events.tsv'
      '';
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p %h/.cache/eureka-prompt";
    };
  };
  systemd.user.timers.eureka-calendar-fetch = {
    Unit = {
      Description = "Timer for eureka-calendar-fetch";
    };
    Timer = {
      OnBootSec = "1min";
      OnUnitActiveSec = "1h";
      Persistent = true;
    };
    Install = {
      WantedBy = [ "timers.target" ];
    };
  };

  xdg.configFile = {
    "opencode/agent/architect.md".source = config.lib.file.mkOutOfStoreSymlink "${agentsDir}/architect.md";
    "opencode/agent/reviewer.md".source = config.lib.file.mkOutOfStoreSymlink "${agentsDir}/reviewer.md";
    "opencode/agent/pm.md".source = config.lib.file.mkOutOfStoreSymlink "${agentsDir}/pm.md";
    "opencode/agent/verifier.md".source = config.lib.file.mkOutOfStoreSymlink "${agentsDir}/verifier.md";
    "opencode/agent/security.md".source = config.lib.file.mkOutOfStoreSymlink "${agentsDir}/security.md";
    "opencode/agent/builder.md".source = config.lib.file.mkOutOfStoreSymlink "${agentsDir}/builder.md";
    "litellm/config.yaml".source = config.lib.file.mkOutOfStoreSymlink "${opencodeDir}/litellm.yaml";
    "opencode/oh-my-openagent.jsonc".source = config.lib.file.mkOutOfStoreSymlink "${opencodeDir}/oh-my-openagent.jsonc";
  };

  programs.opencode = {
    enable = true;
    package = pkgs.llm-agents.opencode;
    rules = ''
      # Agent Workflow

      The **pm** is the sole entry point. Describe your task to it and it will orchestrate the full workflow — architect → builder → reviewer — asking you for input whenever any agent encounters a problem.

      Agents do not share live session context. State passes through file artifacts:
      - **SPEC.md** (repo root) — produced by the architect, read by builder and reviewer
      - Inline context — the pm is responsible for passing relevant state in each Task call
    '';
    settings = {
      plugin = [ "oh-my-openagent" ];
      model = "ollama/qwen3:30b";
      small_model = "ollama/qwen2.5-coder:14b";
      provider.litellm = {
        npm = "@ai-sdk/openai-compatible";
        name = "LiteLLM (proxy)";
        options = {
          baseURL = "http://127.0.0.1:4000/v1";
          apiKey = "litellm";
        };
        models = litellmModels;
      };
      provider.ollama = {
        npm = "@ai-sdk/openai-compatible";
        name = "Ollama (local)";
        options = {
          baseURL = "http://127.0.0.1:11434/v1";
          apiKey = "ollama";
        };
        models = ollamaModels;
      };
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
