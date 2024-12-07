{ pkgs, ... }:
{
  imports = [
    ../../../home-manager/default.nix
    ../../../home-manager/sway.nix
  ];

  home.packages = with pkgs; [
    telegram-desktop
    wofi
    wl-clipboard
    mako
    swaybg
    nautilus
  ];

  programs.kitty = {
    theme = "Catppuccin-Mocha";
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 14;
    };
  };

  programs.helix.settings.theme = "catppuccin_mocha";

  # zsh & oh-my-zsh configurations
  programs.zsh.oh-my-zsh.theme = "dst";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.
}

