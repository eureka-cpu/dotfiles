{ pkgs, lib, config, osConfig ? { }, ... }:
let
  inherit (pkgs) stdenv;

  filterByPlatform = ps:
    let
      inherit (pkgs) hostPlatform;
      inherit (lib.meta) availableOn;
    in
    builtins.filter (p: availableOn hostPlatform p) ps;
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
    git-kitten # kitty-diff-git: `git kitten diff`
    helix
    docker
    llm-agents.claude-code
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

  programs.kasane = {
    enable = true;
    palette = "obi-gamma";
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
    extraConfig =
      let
        inherit (config.programs.kasane.colors)
          cursor foreground background
          selection_foreground selection_background
          black black-bright
          red red-bright
          green green-bright
          yellow yellow-bright
          blue blue-bright
          magenta magenta-bright
          cyan cyan-bright
          white white-bright
          active_tab_foreground active_tab_background
          inactive_tab_foreground inactive_tab_background;
      in
      ''
        cursor                  ${cursor}
        foreground              ${foreground}
        background              ${background}
        selection_foreground    ${selection_foreground}
        selection_background    ${selection_background}
        color0                  ${black}
        color8                  ${black-bright}
        color1                  ${red}
        color9                  ${red-bright}
        color2                  ${green}
        color10                 ${green-bright}
        color3                  ${yellow}
        color11                 ${yellow-bright}
        color4                  ${blue}
        color12                 ${blue-bright}
        color5                  ${magenta}
        color13                 ${magenta-bright}
        color6                  ${cyan}
        color14                 ${cyan-bright}
        color7                  ${white}
        color15                 ${white-bright}
        active_tab_foreground   ${active_tab_foreground}
        active_tab_background   ${active_tab_background}
        inactive_tab_foreground ${inactive_tab_foreground}
        inactive_tab_background ${inactive_tab_background}
        active_border_color     ${black-bright}
        inactive_border_color   ${black}
        bell_border_color       ${yellow}
      '';
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
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
      prompt = "enabled";
      aliases = {
        co = "pr checkout";
        pv = "pr view";
      };
    };
    gitCredentialHelper.enable = true;
    extensions = [ pkgs.gh-dash ];
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

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
