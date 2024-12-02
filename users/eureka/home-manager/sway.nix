{ pkgs, ... }:
{
  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true; # Fixes common issues with GTK 3 apps
    config = {
      modifier = "Mod4";
      terminal = "kitty"; 
      defaultWorkspace = "workspace number 1";
      startup = [
        { command = "kitty"; }
        { command = "brave"; }
      ];
      seat."*" = {
        xcursor_theme = "Adwaita 18";
      };
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
    gtk.enable = true;
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 18;
    x11 = {
      enable = true;
      defaultCursor = "Adwaita";
    };
  };
}
