{ pkgs, ... }:

let
  cursorName = "Adwaita";
  cursorPkg = pkgs.gnome.adwaita-icon-theme;
  cursorSize = 22;
in
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
    cursorTheme = {
      name = cursorName;
      package = cursorPkg;
      size = cursorSize;
    };
  };

  home.pointerCursor = {
    name = cursorName;
    package = cursorPkg;
    size = cursorSize;
    gtk.enable = true;
    x11.enable = true;
  };
}
