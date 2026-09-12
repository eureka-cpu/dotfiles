{ pkgs, config, ... }:
let
  cursorName = "Adwaita";
  cursorPkg = pkgs.adwaita-icon-theme;
  cursorSize = 22;
  inherit (config.programs.kasane.colors) blue foreground;
in
{
  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
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
    gtk3.extraCss = ''
      @define-color accent_color ${blue};
      @define-color accent_bg_color ${blue};
      @define-color accent_fg_color ${foreground};
    '';
    gtk4.extraCss = ''
      @define-color accent_color ${blue};
      @define-color accent_bg_color ${blue};
      @define-color accent_fg_color ${foreground};
    '';
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style = {
      name = "adwaita-dark";
      package = pkgs.adwaita-qt;
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
