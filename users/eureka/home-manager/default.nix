{ pkgs, lib, ... }:
{
  # Home Manager needs a bit of information about you and the paths it should manage.
  home.username = "eureka";
  home.homeDirectory = lib.mkDefault
    (if pkgs.stdenv.isDarwin then
      "/Users/eureka"
    else
      "/home/eureka");

  home.packages = with pkgs; [
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
    # studio
    ffmpeg
    gphoto2
  ] ++ lib.optionals pkgs.stdenv.isLinux (with pkgs; [
    wl-clipboard
    obsidian
    obs-studio
    spotify
    zoom-us
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
