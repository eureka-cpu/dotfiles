{ pkgs, lib, ... }:
{
  imports = [
    ./gtk.nix
    ../../../../home-manager/hyprland.nix
    ../../../../home-manager/default.nix
  ];

  home.packages = with pkgs; [
    nvtopPackages.full
  ];

  programs.kitty = {
    themeFile = "GruvboxMaterialDarkMedium";
    font = {
      name = lib.mkForce "JetBrainsMono Nerd Font";
      size = lib.mkForce 15;
    };
  };
  programs.helix.settings.theme = lib.mkForce "gruvbox_material_dark_medium";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.05"; # Please read the comment before changing.
}
