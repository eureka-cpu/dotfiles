{ pkgs, lib, ... }:
{
  imports = [
    ../../../../home-manager/default.nix
  ];

  programs.kitty = {
    themeFile = "zenwritten_dark";
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 17;
    };
  };
  programs.zsh.oh-my-zsh.theme = "dst";
  programs.helix.settings.theme = "meliora";

  home.stateVersion = "25.05";
}
