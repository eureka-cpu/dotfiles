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
      modifier = "Mod4";
      menu = "wofi --show=drun --gtk-dark";
      terminal = "kitty";
      defaultWorkspace = "workspace number 1";
      startup = [
        { command = "swaybg -i $HOME/Downloads/nixos-wallpaper-catppuccin-mocha.png"; }
        { command = "kitty"; }
        { command = "brave"; }
      ];
      seat."*" = {
        xcursor_theme = "${cursor.name} ${builtins.toString cursor.size}";
      };
      output = {
        "*" = {
          scale = "1.4";
        };
      };
      window.titlebar = false;
    };
    extraConfig = ''
      input type:touchpad {
        natural_scroll enabled
      }
    '';
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
