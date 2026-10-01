{ pkgs, config, ... }:
{
  systemd.user.services.mako = {
    Unit = {
      Description = "Mako notification daemon";
      After = [ "hyprland-session.target" ];
      PartOf = [ "hyprland-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.mako}/bin/mako";
      Restart = "on-failure";
      RestartSec = "3s";
    };
    Install.WantedBy = [ "hyprland-session.target" ];
  };

  systemd.user.services.nm-applet = {
    Unit = {
      Description = "Network Manager applet";
      After = [ "hyprland-session.target" ];
      PartOf = [ "hyprland-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.networkmanagerapplet}/bin/nm-applet";
      Restart = "on-failure";
      RestartSec = "3s";
    };
    Install.WantedBy = [ "hyprland-session.target" ];
  };

  systemd.user.services.anyrun = {
    Unit = {
      Description = "Anyrun launcher daemon";
      After = [ "hyprland-session.target" ];
      PartOf = [ "hyprland-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.anyrun}/bin/anyrun daemon";
      Restart = "on-failure";
      RestartSec = "3s";
    };
    Install.WantedBy = [ "hyprland-session.target" ];
  };

  systemd.user.services.eww = {
    Unit = {
      Description = "Eww widget daemon";
      After = [ "hyprland-session.target" ];
      PartOf = [ "hyprland-session.target" ];
    };
    Service = {
      ExecStartPre = "${pkgs.bash}/bin/bash -c 'pkill -f \"^socat.*socket2\\.sock\" 2>/dev/null; sleep 0.2; true'";
      ExecStart = "${pkgs.eww}/bin/eww daemon --no-daemonize";
      ExecStartPost = "${pkgs.eww}/bin/eww open window";
      Restart = "on-failure";
      RestartSec = "3s";
    };
    Install.WantedBy = [ "hyprland-session.target" ];
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
    config.hyprland.default = [ "hyprland" "gtk" ];
  };
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    settings =
      let
        # Stolen from @iynaix :^)
        openOnWorkspace = workspace: program: "[workspace ${builtins.toString workspace} silent] ${program}";
      in
      # Taken from the below auto-generated config file, updated with some personal touches:
        # https://github.com/hyprwm/Hyprland/blob/bc6b0880dda2607a80f000c134f573c970452a0f/example/hyprland.conf
      {
        # This is an example Hyprland config file.
        # Refer to the wiki for more information.
        # https://wiki.hyprland.org/Configuring/Configuring-Hyprland/

        # Please note not all available settings / options are set here.
        # For a full list, see the wiki

        # You can split this configuration into multiple files
        # Create your files separately and then link them to this file like this:
        # source = ~/.config/hypr/myColors.conf

        ################
        ### MONITORS ###
        ################

        # See https://wiki.hyprland.org/Configuring/Monitors/
        # monitor=name,resolution,position,scale
        #
        # Default:
        # monitor = ",preferred,auto,auto";
        monitor = [
          "desc:HP Inc. HP Z32 CN42411R5T, preferred, auto, 1"
          "desc:ESP eD15T(2022) 0x00011916, preferred, 0x0, 1, transform, 1"
          "Unknown-1, disabled" # fix for upstream wl-roots bug
          ", preferred, auto, 1" # fallback: disable auto-scaling for any unmatched display
        ];
        workspace = [
          "1, monitor:desc:HP Inc. HP Z32 CN42411R5T, default:true, persistent:true"
          "2, monitor:desc:ESP eD15T(2022) 0x00011916, default:true, persistent:true"
        ];

        ###################
        ### MY PROGRAMS ###
        ###################

        # See https://wiki.hyprland.org/Configuring/Keywords/

        # Set programs that you use
        "$terminal" = "kitty";
        "$browser" = "brave";

        #################
        ### AUTOSTART ###
        #################

        # Autostart necessary processes (like notifications daemons, status bars, etc.)
        # Or execute your favorite apps at launch like this:

        # exec-once = $terminal
        # exec-once = nm-applet &
        # exec-once = waybar & hyprpaper & firefox
        exec-once = [
          (openOnWorkspace 1 "$terminal")
          (openOnWorkspace 1 "$browser")
          (openOnWorkspace 2 "$terminal")
          "hyprctl dispatch workspace 1"
          "hyprctl dispatch workspace 2"
        ];

        #############################
        ### ENVIRONMENT VARIABLES ###
        #############################

        # See https://wiki.hyprland.org/Configuring/Environment-variables/

        env = [
          "XCURSOR_SIZE,20"
          "HYPRCURSOR_SIZE,20"
        ];

        #####################
        ### LOOK AND FEEL ###
        #####################

        # Refer to https://wiki.hyprland.org/Configuring/Variables/

        # https://wiki.hyprland.org/Configuring/Variables/#general
        general = {
          gaps_in = 5;
          gaps_out = 10;
          border_size = 0;

          # https://wiki.hyprland.org/Configuring/Variables/#variable-types for info about colors
          # "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
          # "col.inactive_border" = "rgba(595959aa)";

          # Set to true enable resizing windows by clicking and dragging on borders and gaps
          #
          # This setting can sometimes cause focus to be lost on window menus.
          # Use mod+right-click instead.
          resize_on_border = false;

          # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
          allow_tearing = false;
          layout = "dwindle";
        };

        # https://wiki.hyprland.org/Configuring/Variables/#decoration
        decoration = {
          rounding = 0;

          # Change transparency of focused and unfocused windows
          active_opacity = "1.0";
          inactive_opacity = "1.0";
          dim_inactive = true;
          dim_strength = 0.02;
          dim_around = 0.02;

          shadow = {
            enabled = true;
            range = 32;
            render_power = 2;
            scale = 0.9;
          };

          # https://wiki.hyprland.org/Configuring/Variables/#blur
          blur = {
            enabled = true;
            size = 3;
            passes = 1;
            vibrancy = "0.1696";
          };
        };

        # https://wiki.hyprland.org/Configuring/Variables/#animations
        animations = {
          enabled = false;
          bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
          # Default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more
          animation = [
            "windows, 1, 7, myBezier"
            "windowsOut, 1, 7, default, popin 80%"
            "border, 1, 10, default"
            "borderangle, 1, 8, default"
            "fade, 1, 7, default"
            "workspaces, 1, 6, default"
          ];
        };

        # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
        dwindle = {
          pseudotile = true; # Master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
          preserve_split = true; # You probably want this
        };

        # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
        master = {
          new_status = "master";
        };

        # https://wiki.hyprland.org/Configuring/Variables/#misc
        misc = {
          force_default_wallpaper = 0; # Set to 0 or 1 to disable the anime mascot wallpapers
          disable_hyprland_logo = false; # If true disables the random hyprland logo / anime girl background. :(
          disable_splash_rendering = true;
        };

        #############
        ### INPUT ###
        #############

        # https://wiki.hyprland.org/Configuring/Variables/#input
        input = {
          kb_layout = "us";
          kb_variant = "";
          kb_model = "";
          kb_options = "";
          kb_rules = "";
          follow_mouse = 2;
          natural_scroll = true;
          sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
          touchpad = {
            natural_scroll = true;
          };
        };

        # https://wiki.hyprland.org/Configuring/Variables/#gestures
        gestures = { };

        # Example per-device config
        # See https://wiki.hyprland.org/Configuring/Keywords/#per-device-input-configs for more
        device = {
          name = "epic-mouse-v1";
          sensitivity = "-0.5";
        };

        ####################
        ### KEYBINDINGSS ###
        ####################

        # See https://wiki.hyprland.org/Configuring/Keywords/ for more
        "$mainMod" = "SUPER";

        # Opens anyrun if closed, closes it if open
        bindr = "SUPER, SUPER_L, exec, anyrun close 2>/dev/null || anyrun";

        # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
        bind = [
          "$mainMod, Q, killactive,"
          "$mainMod, M, exit,"
          "$mainMod, E, exec, nautilus"
          "$mainMod, V, togglefloating,"
          "$mainMod, P, pseudo," # dwindle

          # Move focus with mainMod + arrow keys
          "$mainMod, L, movefocus, r"
          "$mainMod, H, movefocus, l"
          "$mainMod, K, movefocus, u"
          "$mainMod, J, movefocus, d"

          # Switch workspaces with mainMod + [0-9]
          "$mainMod, 1, workspace, 1"
          "$mainMod, 2, workspace, 2"
          "$mainMod, 3, workspace, 3"
          "$mainMod, 4, workspace, 4"
          "$mainMod, 5, workspace, 5"
          "$mainMod, 6, workspace, 6"
          "$mainMod, 7, workspace, 7"
          "$mainMod, 8, workspace, 8"
          "$mainMod, 9, workspace, 9"
          "$mainMod, 0, workspace, 10"
          "ALT, H, workspace, e-1" # workspace left
          "ALT, L, workspace, e+1" # workspace right

          # Move active window to a workspace with mainMod + SHIFT + [0-9]
          "$mainMod SHIFT, 1, movetoworkspace, 1"
          "$mainMod SHIFT, 2, movetoworkspace, 2"
          "$mainMod SHIFT, 3, movetoworkspace, 3"
          "$mainMod SHIFT, 4, movetoworkspace, 4"
          "$mainMod SHIFT, 5, movetoworkspace, 5"
          "$mainMod SHIFT, 6, movetoworkspace, 6"
          "$mainMod SHIFT, 7, movetoworkspace, 7"
          "$mainMod SHIFT, 8, movetoworkspace, 8"
          "$mainMod SHIFT, 9, movetoworkspace, 9"
          "$mainMod SHIFT, 0, movetoworkspace, 10"
          "ALT SHIFT, H, movetoworkspace, e-1" # move window to workspace left
          "ALT SHIFT, L, movetoworkspace, e+1" # move window to worksapce right

          # Scroll through existing workspaces with mainMod + scroll
          "$mainMod, mouse_down, workspace, e+1"
          "$mainMod, mouse_up, workspace, e-1"
        ];

        # Move/resize windows with mainMod + LMB/RMB and dragging
        bindm = [
          "$mainMod, mouse:272, movewindow"
          "$mainMod, mouse:273, resizewindow"
        ];

        ##############################
        ### WINDOWS AND WORKSPACES ###
        ##############################

        # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
        # See https://wiki.hyprland.org/Configuring/Workspace-Rules/ for workspace rules

      };
  };

  programs.eww = {
    enable = true;
    package = pkgs.eww;
    configDir = ./eww;
  };

  home.packages = with pkgs; [
    grim
    anyrun
    mako
    nautilus
    zathura
    image-roll
    celluloid
    pavucontrol
    playerctl
    networkmanagerapplet
    gcalcli
  ];

  xdg = {
    configFile =
      let
        inherit (config.programs.kasane.colors)
          background active_tab_background selection_background
          black-bright blue blue-bright foreground white red;
        hex = s: builtins.substring 1 (builtins.stringLength s - 1) s;
      in
      {
        "rofi/config.rasi".source = ./rofi/config.rasi;
        "rofi/kasane.rasi".text = ''
          * {
              bg:         ${background};
              surface:    ${active_tab_background};
              border-col: ${black-bright};
              accent:     ${blue};
              fg:         ${foreground};
              fg-dim:     ${white};
              urgent:     ${red};
              alt-bg:     #2a2c33;

              background-color: transparent;
              text-color:       @fg-dim;
          }

          window {
              location:         north;
              anchor:           north;
              x-offset:         0px;
              y-offset:         180px;
              border:           1px;
              border-radius:    10px;
              border-color:     @border-col;
              width:            660px;
              background-color: @bg;
              spacing:          0;
              children:         [mainbox];
          }

          mainbox {
              spacing:  0;
              children: [inputbar, listview];
          }

          inputbar {
              padding:          11px 16px;
              background-color: transparent;
              border-radius:    10px 10px 0px 0px;
              spacing:          10px;
              children:         [prompt, entry, case-indicator];
          }

          entry, case-indicator {
              text-font:        inherit;
              text-color:       @fg;
              background-color: transparent;
          }

          prompt {
              text-color:       @accent;
              background-color: transparent;
          }

          listview {
              padding:          6px;
              border-radius:    0px 0px 10px 10px;
              border:           1px 0px 0px 0px;
              border-color:     @border-col;
              background-color: transparent;
              dynamic:          true;
              lines:            8;
              fixed-num-lines:  false;
              spacing:          2px;
          }

          element {
              padding:          7px 10px;
              vertical-align:   0.5;
              border-radius:    6px;
              text-color:       @fg-dim;
              background-color: transparent;
          }

          element.alternate.normal,
          element.alternate.active {
              background-color: @alt-bg;
          }

          element.selected.normal,
          element.selected.active {
              background-color: @surface;
              text-color:       @fg;
          }

          element.normal.urgent,
          element.selected.urgent {
              text-color: @urgent;
          }

          element-icon {
              size:             1.4em;
              margin:           0px 10px 0px 0px;
              vertical-align:   0.5;
              background-color: transparent;
          }

          element-text {
              vertical-align:   0.5;
              background-color: transparent;
              text-color:       inherit;
          }
        '';
        "anyrun/config.ron".text = ''
          Config(
            x: Fraction(0.5),
            y: Absolute(270),
            width: Absolute(600),
            height: Absolute(0),
            hide_icons: false,
            ignore_exclusive_zones: true,
            layer: Overlay,
            hide_plugin_info: true,
            close_on_click: true,
            show_results_immediately: false,
            max_entries: Some(4),
            plugins: [
              "${pkgs.anyrun}/lib/libapplications.so",
            ],
            keybinds: [
              Keybind(key: "Return", action: Select),
              Keybind(key: "Up",     action: Up),
              Keybind(key: "Down",   action: Down),
              Keybind(key: "ISO_Left_Tab", action: Up, shift: true),
              Keybind(key: "Tab",    action: Down),
              Keybind(key: "Escape", action: Close),
            ],
          )
        '';
        "anyrun/style.css".text = ''
          * {
            font-family: "JetBrainsMono Nerd Font";
            font-size: 13px;
            outline: none;
          }

          window {
            background: transparent;
          }

          box.main {
            padding: 0;
            margin: 0;
            border-radius: 10px;
            border: 1px solid ${black-bright};
            background-color: ${background};
          }

          entry {
            background-color: transparent;
            box-shadow: none;
            border: none;
            background-image: url("file:///run/current-system/sw/share/icons/hicolor/scalable/apps/nix-snowflake-white.svg");
            background-repeat: no-repeat;
            background-position: 12px center;
            background-size: 16px 16px;
          }

          text {
            min-height: 0;
            padding: 12px 14px 12px 34px;
            color: ${foreground};
            caret-color: ${blue};
            background-color: transparent;
          }

          text placeholder {
            color: ${black-bright};
          }

          .matches {
            border-top: 1px solid ${active_tab_background};
            background-color: transparent;
            padding: 3px;
          }

          list.plugin {
            background-color: transparent;
          }

          .match {
            padding: 5px 10px;
            border-radius: 5px;
            background-color: transparent;
            min-height: 0;
          }

          .match:selected {
            background-color: ${active_tab_background};
          }

          label.match {
            color: ${white};
          }

          label.match.description {
            font-size: 0;
            min-height: 0;
            margin: 0;
            padding: 0;
            opacity: 0;
          }

          list.plugin image {
            -gtk-icon-size: 16px;
            min-width: 16px;
            min-height: 16px;
            margin-right: 8px;
          }
        '';
        "mako/config".text = ''
          background-color=${background}ff
          text-color=${foreground}ff
          border-size=0
          border-radius=0
          font=JetBrainsMono Nerd Font 12
          layer=overlay
          max-history=100
          icons=1
          max-icon-size=64
        '';
      };
    mimeApps.defaultApplications = {
      "text/plain" = [ "helix.desktop" ];
      "application/pdf" = [ "zathura.desktop" ];
      "image/*" = [ "image-roll.desktop" ];
      "video/png" = [ "celluloid.desktop" ];
      "video/jpg" = [ "celluloid.desktop" ];
      "video/*" = [ "celluloid.desktop" ];
    };
  };
}
