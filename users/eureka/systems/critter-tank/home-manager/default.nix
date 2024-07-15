{ pkgs, nix-colors, ... }:
{
  imports = [
    ./gtk.nix
    ../../../home-manager/hyprland.nix
    ../../../home-manager/default.nix
    nix-colors.homeManagerModules.default
  ];

  home.packages = with pkgs; [
    nvtopPackages.full
    grim
    eww
    rofi-wayland
    mako
    swww
    xfce.thunar
    zathura
    image-roll
    celluloid
  ];

  programs.kitty = {
    theme = "Gruvbox Material Dark Medium";
    font.name = "JetBrainsMono Nerd Font";
  };
  programs.helix.settings.theme = "gruvbox_material_dark_medium";
  programs.zsh.oh-my-zsh.theme = "dst";

  xdg = {
    configFile = {
      rofi = {
        source = ./rofi;
        recursive = true;
      };
    };
    mimeApps.defaultApplications = {
      "text/plain" = [ "helix.desktop" ];
      "application/pdf" = [ "zathura.desktop" ];
      "image/*" = [ "image-roll.desktop" ];
      "video/png" = [ "celluloid.desktop" ];
      "video/jpg" = [ "celluloid.desktop" ];
      "video/*" = [ "celluloid.desktop" ];
    };
  };

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.05"; # Please read the comment before changing.
}
