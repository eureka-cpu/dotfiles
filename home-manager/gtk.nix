{ pkgs, ... }:

# let
  # cursor = pkgs.simp1e-cursors;
  # cursorName = "Simp1e-Adw-Dark";
# in
{
  gtk = {
    enable = true;
    theme.name = "gruvbox-dark";
    iconTheme = {
      name = "Gruvbox-Plus-Dark";
      package = pkgs.gruvbox-plus-icons;
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
