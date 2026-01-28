{ config, pkgs, ... }:
let
  colors = import ./colors.nix;

  customMic = pkgs.writeShellScriptBin "mic.sh" ''
    #!/usr/bin/env bash
    
    if wpctl get-volume @DEFAULT_SOURCE@ | grep -q MUTED; then
      echo '{"text":"󰍬 ","class":"muted"}'
    else
      echo  '{"text":"󰍬 "}'
    fi
  '';
in
{
  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        spacing = 12;

        modules-left = [
          "hyprland/workspaces"
          "hyprland/window"
        ];

        modules-center = [
          "clock"
        ];

        modules-right = [
          "custom/mic"
          "pulseaudio"
          "cpu"
          "memory"
          "network"
          "tray"
        ];

        "hyprland/workspaces" = {
          format = "{icon}";
          format-icons = {
            "1" = "I";
            "2" = "II";
            "3" = "III";
            "4" = "IV";
            "5" = "V";
            "6" = "VI";
            "7" = "VII";
            "8" = "VIII";
            "9" = "IX";
            "10" = "X";
          };
        };

        clock = {
          format = "{:%H:%M}  ";
          format-alt = "{:%A, %B %d, %Y (%R)}  ";
          tooltip-format = "<tt><small>{calendar}</small></tt>";

          calendar = {
            mode = "year";
            "mode-mon-col" = 3;
            "weeks-pos" = "right";
            "on-scroll" = 1;
            "on-click-right" = "mode";
            format = {
              months = "<span color='#ffead3'><b>{}</b></span>";
              days = "<span color='#ecc6d9'><b>{}</b></span>";
              weeks = "<span color='#99ffdd'><b>W{}</b></span>";
              weekdays = "<span color='#ffcc66'><b>{}</b></span>";
              today = "<span color='#ff6699'><b><u>{}</u></b></span>";
            };
          };

          actions = {
            "on-click-right" = "mode";
            "on-scroll-up" = "shift_up";
            "on-scroll-down" = "shift_down";
          };
        };

        "custom/mic" = {
          exec = "${customMic}/bin/mic.sh";
          interval = 1;
          return-type = "json";
          on-click = "wpctl set-mute @DEFAULT_SOURCE@ toggle";
        };

        pulseaudio = {
          format = "{icon}";
          format-muted = "󰝟 ";
          format-icons = {
            default = [ "󰕿 " "󰖀 " "󰕾 " ];
          };
          scroll-step = 1;
          on-click = "pavucontrol";
        };

        cpu = {
          format = "󰻠 ";
          interval = 1;
          graph = true;
        };

        memory = {
          format = "󰍛 ";
          interval = 2;
          graph = true;
        };

        network = {
          format-ethernet = "󰈀 ";
          format-wifi = "󰖩 ";
          format-disconnected = "󰖪 ";
          tooltip-format = "{ifname}";
          tooltip-format-ethernet = "{ifname}  ";
        };

        tray = {};
      };
    };

    style = ''
      * {
        font-family: JetBrainsMono Nerd Font;
      }

      window#waybar {
        background: ${colors.bg};
        color: ${colors.fg};
        border-bottom: 2px solid ${colors.border};
      }

      #waybar > widget {
        background: transparent;
        border-radius: 0;
        padding: 0;
        margin: 0;
      }

      #waybar .modules-left > widget,
      #waybar .modules-center > widget {
        font-size: 12px;
        margin: 0 6px;
      }

      #waybar .modules-right > widget {
        font-size: 20px;
      }

      #custom-mic.muted {
        color: #ff5555;
      }

      #tray > widget {
        margin: 0 6px;
      }

      #tray image {
        min-width: 20px;
        min-height: 20px;
      }
    '';
  };
}

