{ config, pkgs, ... }:
let
  inherit (config.home-manager.users.eureka.programs.kasane) palette;
  p = builtins.fromJSON (builtins.readFile "${pkgs.kasane}/palettes/${palette}.json");
in
{
  services.greetd.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;

  programs.regreet = {
    enable = true;

    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
    cursorTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
    font = {
      name = "JetBrainsMono Nerd Font";
      package = pkgs.nerd-fonts.jetbrains-mono;
      size = 12;
    };
    settings = {
      GTK.application_prefer_dark_theme = true;
      commands = {
        reboot = [ "systemctl" "reboot" ];
        poweroff = [ "systemctl" "poweroff" ];
      };
    };

    extraCss = ''
      * {
        font-family: "JetBrainsMono Nerd Font";
        color: ${p.foreground};
      }

      window, .background {
        background-color: ${p.background};
      }

      /* Form card */
      .main-box {
        background-color: ${p.active_tab_background};
        padding: 32px 40px;
      }

      /* Entry fields */
      entry {
        background-color: ${p.background};
        color: ${p.foreground};
        caret-color: ${p."blue"};
        border: 1px solid ${p."black-bright"};
        border-radius: 0;
        box-shadow: none;
        padding: 9px 12px;
      }
      entry:focus {
        border-color: ${p."blue"};
        box-shadow: none;
      }

      /* All buttons */
      button {
        background-color: ${p.active_tab_background};
        color: ${p.foreground};
        border: 1px solid ${p."black-bright"};
        border-radius: 0;
        box-shadow: none;
        padding: 8px 18px;
      }
      button:hover {
        background-color: ${p.selection_background};
        border-color: ${p."blue"};
        color: ${p."white-bright"};
      }
      button:active {
        background-color: ${p.selection_background};
        box-shadow: none;
      }

      /* Login / suggested-action button */
      button.suggested-action {
        background-color: ${p.selection_background};
        border-color: ${p."blue"};
      }
      button.suggested-action:hover {
        border-color: ${p."blue-bright"};
        color: ${p."white-bright"};
      }

      /* Destructive buttons (reboot/shutdown) */
      button.destructive-action {
        color: ${p."red"};
        border-color: ${p."black-bright"};
      }
      button.destructive-action:hover {
        color: ${p."red-bright"};
        border-color: ${p."red"};
      }

      /* Dropdowns */
      combobox button,
      dropdown > button {
        border-radius: 0;
      }

      /* Labels */
      label {
        color: ${p.foreground};
      }
      label.error {
        color: ${p."red"};
      }

      /* Separators */
      separator {
        background-color: ${p."black-bright"};
        min-height: 1px;
      }
    '';
  };
}
