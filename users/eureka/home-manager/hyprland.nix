{ pkgs, user, ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;
    settings =
      let
        swww = "${pkgs.swww}/bin/swww";
        eww = "${pkgs.eww}/bin/eww";
        mako = "${pkgs.mako}/bin/mako";

        homeDirectory = user.homeDirectory;
        wallpaper = "${homeDirectory}/Wallpapers/stairs.jpg";
        mynixui = "${homeDirectory}/Code/mynixui/eww";
        onStart = pkgs.writeShellScriptBin "start.sh" ''
          # start wallpaper daemon and set wallpaper
          sleep 2; ${swww} init & ${swww} img ${wallpaper} &

          # start widget daemon and open widgets
          ${eww} daemon -c ${mynixui} & ${eww} open window -c ${mynixui} &

          # start notification daemon
          ${mako}
        '';
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
        ];
        workspace = "1, monitor:ESP eD15T(2022) 0x00011916, default:true, persistent:true";

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
          "${onStart}/bin/start.sh"
          (openOnWorkspace 2 "$terminal")
          (openOnWorkspace 2 "$browser")
          (openOnWorkspace 1 "$terminal")
          "hyprctl dispatch workspace 2"
          "hyprctl dispatch workspace 1"
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
          border_size = 2;

          # https://wiki.hyprland.org/Configuring/Variables/#variable-types for info about colors
          "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
          "col.inactive_border" = "rgba(595959aa)";

          # Set to true enable resizing windows by clicking and dragging on borders and gaps
          resize_on_border = false;

          # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
          allow_tearing = false;
          layout = "dwindle";
        };

        # https://wiki.hyprland.org/Configuring/Variables/#decoration
        decoration = {
          rounding = 5;

          # Change transparency of focused and unfocused windows
          active_opacity = "1.0";
          inactive_opacity = "1.0";

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
          enabled = true;
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
          follow_mouse = 1;
          natural_scroll = true;
          sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
          touchpad = {
            natural_scroll = true;
          };
        };

        # https://wiki.hyprland.org/Configuring/Variables/#gestures
        gestures = {
          workspace_swipe = false;
        };

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

        # Opens rofi on first press, closes it on second
        bindr = "SUPER, SUPER_L, exec, pkill rofi || rofi -show drun -show-icons";

        # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
        bind = [
          "$mainMod, Q, killactive,"
          "$mainMod, M, exit,"
          "$mainMod, E, exec, thunar"
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

        # Example windowrule v1
        # windowrule = float, ^(kitty)$

        # Example windowrule v2
        # windowrulev2 = float,class:^(kitty)$,title:^(kitty)$

        windowrulev2 = "suppressevent maximize, class:.*"; # You'll probably like this.
      };
  };
}
