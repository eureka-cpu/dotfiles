{ pkgs, ... }:
{
  home.packages = with pkgs; [
    xdg-desktop-portal-gtk

    # XFCE Core
    xfce.xfwm4
    xfce.xfce4-panel
    xfce.xfce4-session
    xfce.xfce4-settings
    xfce.thunar
    xfce.mousepad
    xfce.xfce4-terminal
    xfce.xfce4-appfinder
    xfce.xfce4-power-manager
    xfce.xfce4-notifyd
    xfce.xfce4-whiskermenu-plugin

    # Optional Extras
    xfce.gigolo
    xfce.xfce4-screenshooter
    xfce.parole
  ];
}
