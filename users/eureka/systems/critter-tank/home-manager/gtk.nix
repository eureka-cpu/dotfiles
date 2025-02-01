{ pkgs, nix-colors, ... }:
let
  inherit (nix-colors.lib-contrib { inherit pkgs; }) gtkThemeFromScheme;# colorSchemeFromPicture;
  cursorName = "Adwaita";
  cursorPkg = pkgs.adwaita-icon-theme;
  cursorSize = 20;
  # colorScheme = colorSchemeFromPicture {
  #   path = ./wallpapers/gruvbox-mountain-village.jpg;
  #   variant = "dark";
  # };
  colorScheme = nix-colors.colorSchemes.gruvbox-material-dark-medium;
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
