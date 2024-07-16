{ pkgs, ... }:
{
  home.packages = with pkgs; [
    gnomeExtensions.color-picker
    gnomeExtensions.pop-shell
    gnomeExtensions.user-themes
    xdg-desktop-portal
    xdg-desktop-portal-gnome
  ];

  dconf.settings = {
    # shell extensions
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "pop-shell@system76.com"
        "user-theme@gnome-shell-extensions.gcampax.github.com"
      ];
    };

    # keybindings
    "org/gnome/shell/keybindings" = {
      toggle-quick-settings = []; # turn off focus power menu
      toggle-message-tray = ["<Super>n"];
      focus-active-notification = [];
    };
    "org/gnome/desktop/wm/keybindings" = {
      close = ["<Super>q"];
      minimize = [];
      maximize = [];
      toggle-maximized = ["<Super>m"];
      # workspace/monitor settings
      switch-to-workspace-left = ["<Alt>h"];
      switch-to-workspace-right = ["<Alt>l"];
      move-to-workspace-left = ["<Shift><Alt>h"];
      move-to-workspace-right = ["<Shift><Alt>l"];
      move-to-monitor-down = [];  # handled by pop-shell
      move-to-monitor-left = [];  #
      move-to-monitor-right = []; #
      move-to-monitor-up = [];    #
    };
    "org/gnome/settings-daemon/plugins/media-keys" = {
      screensaver = []; # turn off lock screen
    };
  };
}
