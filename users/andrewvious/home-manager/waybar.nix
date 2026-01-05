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
        height = 26;
        spacing = 12;

        modules-left = [
          "hyprland/workspaces"
          "hyprland/window"
        ];

        modules-center = [
          "clock"
        ];

        modules-right = [
          "network"
          "pulseaudio"
          "cpu"
          "memory"
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
        
        network = {
          format-ethernet = "󰈀";
          format-wifi = "󰖩";
          format-disconnected = "󰖪";
          tooltip = "{ip}";
        };
        
        pulseaudio = {
          format = "{icon}";
          format-muted = "󰝟";
          format-icons = {
            default = [ "󰕿" "󰖀" "󰕾" ];
          };
          tooltip = "{volume}%";
        };
        
        cpu = {
          format = "󰻠";
          max-value = 100;
          interval = 1;
          graph = true;
          tooltip = "{usage}%";
        };
        
        memory = {
          format = "󰍛";
          max-value = 100;
          interval = 2;
          graph = true;
          tooltip = "{used} / {total} GB";
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

      #waybar .modules-left widget,
      #waybar .modules-center widget {
        background: ${colors.moduleBg};
        color: ${colors.fg};
        padding: 6px 6px;
        margin: 4px 4px;
        border-radius: 8px;
        font-size: 12px;
      }
      
      #waybar .modules-right > widget {
        background: ${colors.moduleBg};
        color: ${colors.fg};
        border-radius: 6px;
        padding: 4px 10px;
        margin: 0px 6px;
        transition: background 0.2s;
        font-size: 20px;
      }

      #waybar .modules-right {
        padding-right: 12px;
      }

      #waybar .modules-right > widget > label {
        color: ${colors.fg};
        padding: 4px 10px;
      }
      
      #waybar .modules-right > widget:hover {
        background: ${colors.accentSecondary};
      }
      
      #cpu > bar,
      #memory > bar {
        background-color: ${colors.accentPrimary};
        border-radius: 3px;
        margin-top: 3px;
        margin-bottom: 3px;
      }
      
      #tray {
        background: transparent;
        margin-left: 10px;
      }
    '';
  };
}

