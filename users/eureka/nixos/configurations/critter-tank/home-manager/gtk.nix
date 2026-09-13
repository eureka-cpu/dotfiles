{ pkgs, config, ... }:
let
  cursorName = "Adwaita";
  cursorPkg = pkgs.adwaita-icon-theme;
  cursorSize = 20;
  inherit (config.programs.kasane.colors) blue foreground background;

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
      package = pkgs.gruvbox-plus-icons.override { folder-color = "jade"; };
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
      @define-color window_fg_color ${foreground};
      @define-color view_fg_color ${foreground};
      @define-color headerbar_fg_color ${foreground};
      @define-color card_fg_color ${foreground};
      @define-color popover_fg_color ${foreground};
      @define-color sidebar_fg_color ${foreground};
      @define-color theme_fg_color ${foreground};
      @define-color theme_text_color ${foreground};
      * { color: ${foreground}; }

      placessidebar {
        background-color: #2e2e32;
      }
      placessidebar row {
        min-height: 36px;
        color: alpha(${foreground}, 0.7);
      }
      placessidebar row > revealer {
        padding-left: 14px;
        padding-right: 14px;
      }
      .sidebar row {
        border-radius: 9px;
        margin-left: 4px;
        margin-right: 4px;
      }
      placessidebar row:selected {
        background-color: alpha(currentColor, 0.1);
        color: ${foreground};
      }
      placessidebar row.activatable:hover {
        background-color: alpha(currentColor, 0.07);
      }
      placessidebar row image.sidebar-icon {
        opacity: 0.7;
      }
    '';
    gtk4.extraCss = ''
      @define-color accent_color ${blue};
      @define-color accent_bg_color ${blue};
      @define-color accent_fg_color ${foreground};
      @define-color window_fg_color ${foreground};
      @define-color view_fg_color ${foreground};
      @define-color headerbar_fg_color ${foreground};
      @define-color card_fg_color ${foreground};
      @define-color popover_fg_color ${foreground};
      @define-color sidebar_fg_color ${foreground};
      * {
        --window-fg-color: ${foreground};
        --view-fg-color: ${foreground};
        --headerbar-fg-color: ${foreground};
        --card-fg-color: ${foreground};
        --popover-fg-color: ${foreground};
        --sidebar-fg-color: ${foreground};
        --secondary-sidebar-fg-color: ${foreground};
        --dialog-fg-color: ${foreground};
        --thumbnail-fg-color: ${foreground};
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
