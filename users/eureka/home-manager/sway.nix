{ pkgs, ... }:
let
  cursor = {
    name = "Adwaita";
    size = 22;
  };
in
{
  wayland.windowManager.sway = {
    enable = true;
    xwayland = true;
    wrapperFeatures = {
      base = true;
      gtk = true; # Fixes common issues with GTK 3 apps
    };
    config = {
      modifier = "Mod4"; # Super Key
      menu = "wofi --show=drun --gtk-dark";
      terminal = "kitty";
      defaultWorkspace = "workspace number 1";
      startup = [
        { command = "swaybg -i $HOME/Downloads/bunnies-road.png"; }
        { command = "kitty"; }
        { command = "brave"; }
      ];
      seat."*" = {
        xcursor_theme = "${cursor.name} ${builtins.toString cursor.size}";
      };
      input = {
        "*" = {
          # natty scroll master race
          natural_scroll = "enabled";
        };
        "type:touchpad" = {
          # Default uses button areas instead of
          # the entire touchpad area as the input
          click_method = "clickfinger";
          # 'lrm' treats 1 finger as left click,
          # 2 fingers as right click, and 3 fingers as middle click
          clickfinger_button_map = "lrm";
        };
      };
      output."*" = {
        scale = "1.4";
      };
      window.titlebar = false;
    };
  };

  programs.wofi.enable = true;

  services.gnome-keyring.enable = true;

  home.pointerCursor = {
    inherit (cursor) name size;
    gtk.enable = true;
    package = pkgs.adwaita-icon-theme;
    x11 = {
      enable = true;
      defaultCursor = cursor.name;
    };
  };
}
