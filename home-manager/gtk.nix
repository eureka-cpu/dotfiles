{ pkgs, ... }:

# let
  # cursor = pkgs.simp1e-cursors;
  # cursorName = "Simp1e-Adw-Dark";
# in
{
  gtk = {
    enable = true;
    theme = {
      name = "gruvbox-dark";
      package = pkgs.gruvbox-dark-gtk;
    };
    iconTheme = {
      name = "Gruvbox-Plus-Dark";
      package = pkgs.gruvbox-plus-icons;
    };
    gtk3.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };
    gtk4.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };
  };
  # home.pointerCursor = {
  #   package = cursor;
  #   name = cursorName;
  #   size = 21;
  #   gtk.enable = true;
  #   # x11.enable = true;
  # };
}
