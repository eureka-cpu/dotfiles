{ config, pkgs, ... }:
let
  colors = import ./colors.nix;
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
          "pulseaudio"
          "network"
          "cpu"
          "memory"
          "battery"
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
        		"mode"          = "year";
        		"mode-mon-col"  = 3;
        		"weeks-pos"     = "right";
        		"on-scroll"     = 1;
        		"on-click-right"= "mode";
        		format = {
        			"months"=     "<span color='#ffead3'><b>{}</b></span>";
        			"days"=       "<span color='#ecc6d9'><b>{}</b></span>";
        			"weeks"=      "<span color='#99ffdd'><b>W{}</b></span>";
        			"weekdays"=   "<span color='#ffcc66'><b>{}</b></span>";
        			"today"=      "<span color='#ff6699'><b><u>{}</u></b></span>";
        		};
        	};

        	actions = {
        		"on-click-right"= "mode";
        		"on-scroll-up"= "shift_up";
        		"on-scroll-down"= "shift_down";
        	};
        };

        pulseaudio = {
          format = "{volume}% {icon}";
          format-muted = "󰝟";
          format-icons = {
            default = [ "󰕿" "󰖀" "󰕾" ];
          };
        };

        network = {
          format-ethernet = "󰈀";
          format-disconnected = "󰖪";
        };
      };
    };

    style = ''
      * {
        font-family: JetBrainsMono Nerd Font;
        font-size: 12px;
      }

      window#waybar {
        background: ${colors.gray1};
        color: ${colors.gray4};
      }

      #workspaces button {
        color: ${colors.gray3};
      }

      #workspace button.active {
        color: ${colors.gray4};
      }

      #workspace button.urgent {
        color: ${colors.gray2};
      }

      #clock {
        padding: 0 10px;
      }
    '';
  };
}

