{ pkgs, ... }:
{
  home.packages = with pkgs; [
    xfce.xfwm4
    xfce.xfwm4-themes
    xfce.xfce4-whiskermenu-plugin
  ];

  dconf.settings = {
    # Window manager settings for xfwm4
    "xfce4/xfwm4" = {
      # Super key used as a modifier for window management actions
      "use_super_key" = true;

      # Window management keybindings (similar to GNOME)
      "close_key" = "<Super>q"; # Close window (Super+q)
      "maximize_key" = "<Super>m"; # Toggle maximize (Super+m)
      "toggle_maximized_key" = "<Super>m"; # Maximize window toggle (Super+m)

      # Workspace switching (mimicking GNOME keybindings)
      "switch_to_workspace_left" = "<Alt>h"; # Move to the left workspace (Alt+h)
      "switch_to_workspace_right" = "<Alt>l"; # Move to the right workspace (Alt+l)
      "move_to_workspace_left" = "<Shift><Alt>h"; # Move window left (Shift+Alt+h)
      "move_to_workspace_right" = "<Shift><Alt>l"; # Move window right (Shift+Alt+l)

      # Monitor switching (optional)
      "move_to_monitor_left" = ""; # Not mapped, but you can customize
      "move_to_monitor_right" = ""; # Not mapped, but you can customize
      "move_to_monitor_up" = ""; # Not mapped, but you can customize
      "move_to_monitor_down" = ""; # Not mapped, but you can customize
    };

    # Additional keybindings (you may want to disable these for a minimal setup)
    "xfce4-keyboard-shortcuts" = {
      "custom/<Super>n" = "toggle-message-tray"; # Super+n to toggle the message tray (similar to GNOME)
      "custom/<Super>t" = "toggle-quick-settings"; # Super+t for quick settings (optional, like GNOME)
      "custom/<Super>h" = "focus-active-notification"; # Super+h for focus on active notification
    };
  };
}
