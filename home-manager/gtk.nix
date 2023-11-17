{ pkgs, ... }:

let
  cursor = pkgs.simp1e-cursors;
  cursorName = "Simp1e-Gruvbox-Dark";
in
{
  gtk = {
    enable = true;
    theme.name = "gruvbox-dark";

    # Uncomment this once the icons gets merged
    # into nixpkgs
    # 
    # iconTheme = {
    #   name = "Gruvbox-Plus-Dark";
    #   package = pkgs.gruvbox-plus-icon-pack;
    # };
    cursorTheme = {
      size = 24;
      package = cursor;
      name = cursorName;
    };
  };
  home.pointerCursor = {
    package = cursor;
    name = cursorName;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };
}
