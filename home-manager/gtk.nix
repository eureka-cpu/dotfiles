{ pkgs, inputs, ... }:

let
  inherit (inputs.nix-colors.lib-contrib { inherit pkgs; }) gtkThemeFromScheme colorSchemeFromPicture;
  cursorName = "Adwaita";
  cursorPkg = pkgs.adwaita-icon-theme;
  cursorSize = 16;
  colorScheme = colorSchemeFromPicture {
    path = ./wallpapers/swirl.jpg;
    variant = "dark";
  };
in
{
  gtk = {
    enable = true;
    theme = {
      name = "${colorScheme.slug}";
      package = gtkThemeFromScheme { scheme = colorScheme; };
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
