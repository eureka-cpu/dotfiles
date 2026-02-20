{ pkgs, ... }:

let
  cursorName = "Adwaita";
  cursorPkg = pkgs.adwaita-icon-theme;
  cursorSize = 20;
in
{
  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
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
