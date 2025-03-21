{ pkgs, ... }:
{
  gtk = {
    enable = true;
    iconTheme = {
      name = "Colloid";
      package = pkgs.colloid-icon-theme;
    };
    theme = {
      name = "Nordic-darker";
      package = pkgs.nordic;
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
  home.sessionVariables.GTK_THEME = "Nordic-darker";
  dconf.settings = {
    "org/gnome/shell/extensions/user-theme" = {
      name = "Nordic-darker";
    };
  };
}
