{ pkgs, ... }:
{
  imports = [
    ./gtk.nix
    ../../../../home-manager/gnome.nix
    ../../../../home-manager/default.nix
  ];

  home.packages = with pkgs; [
    # comms
    telegram-desktop
    # studio
    inkscape
    kdePackages.kdenlive
    krita
    reaper
    blender
    steam
    libreoffice
  ];

  programs.kitty = {
    themeFile = "kanagawabones";
    font.name = "JetBrainsMono Nerd Font";
  };
  programs.helix.settings.theme = "kanabox_default";

  home.stateVersion = "23.11";
}

