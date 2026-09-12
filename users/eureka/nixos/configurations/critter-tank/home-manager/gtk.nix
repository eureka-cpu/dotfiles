{ pkgs, config, ... }:
let
  cursorName = "Adwaita";
  cursorPkg = pkgs.adwaita-icon-theme;
  cursorSize = 20;
  colors = config.programs.kasane.colors;
in
{
  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    font = {
      name = "Noto Sans";
      size = 11;
    };
    iconTheme = {
      name = "Gruvbox-Plus-Dark";
      package = pkgs.gruvbox-plus-icons.override {
        folder-color = "jade";
      };
    };
    cursorTheme = {
      name = cursorName;
      package = cursorPkg;
      size = cursorSize;
    };
    gtk3.extraCss = ''
      @define-color accent_color ${colors.blue};
      @define-color accent_bg_color ${colors.blue};
      @define-color accent_fg_color ${colors.foreground};
      @define-color window_fg_color ${colors.foreground};
      @define-color view_fg_color ${colors.foreground};
      @define-color headerbar_fg_color ${colors.foreground};
      @define-color card_fg_color ${colors.foreground};
      @define-color popover_fg_color ${colors.foreground};
      @define-color sidebar_fg_color ${colors.foreground};
      @define-color theme_fg_color ${colors.foreground};
      @define-color theme_text_color ${colors.foreground};
    '';
    gtk4.extraCss = ''
      @define-color accent_color ${colors.blue};
      @define-color accent_bg_color ${colors.blue};
      @define-color accent_fg_color ${colors.foreground};
      @define-color window_fg_color ${colors.foreground};
      @define-color view_fg_color ${colors.foreground};
      @define-color headerbar_fg_color ${colors.foreground};
      @define-color card_fg_color ${colors.foreground};
      @define-color popover_fg_color ${colors.foreground};
      @define-color sidebar_fg_color ${colors.foreground};
      * {
        --window-fg-color: ${colors.foreground};
        --view-fg-color: ${colors.foreground};
        --headerbar-fg-color: ${colors.foreground};
        --card-fg-color: ${colors.foreground};
        --popover-fg-color: ${colors.foreground};
        --sidebar-fg-color: ${colors.foreground};
        --secondary-sidebar-fg-color: ${colors.foreground};
        --dialog-fg-color: ${colors.foreground};
        --thumbnail-fg-color: ${colors.foreground};
      }
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

  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
    gtk-theme = "adw-gtk3-dark";
    font-name = "Noto Sans 11";
    document-font-name = "Noto Sans 11";
    monospace-font-name = "JetBrainsMono Nerd Font 13";
  };

  home.pointerCursor = {
    name = cursorName;
    package = cursorPkg;
    size = cursorSize;
    gtk.enable = true;
    x11.enable = true;
  };
}
