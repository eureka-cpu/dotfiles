{ pkgs, ... }:
{
  imports = [
    ./gtk.nix
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
    themeFile = "GruvboxMaterialDarkMedium";
    font.name = "JetBrainsMono Nerd Font";
  };
  programs.helix.settings.theme = "gruvbox_material_dark_medium";

  home.stateVersion = "23.11";
}

