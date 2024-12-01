{ pkgs, ... }:
{
  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true; # Fixes common issues with GTK 3 apps
    config = {
      modifier = "Mod4";
      terminal = "kitty"; 
      startup = [
        { command = "kitty"; }
        { command = "brave"; }
      ];
    };
    extraConfig = ''
      input type:touchpad {
        natural_scroll enabled
      }
    '';
  };

  services.gnome-keyring.enable = true;

  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 18;
    x11 = {
      enable = true;
      defaultCursor = "Adwaita";
    };
  };
}
