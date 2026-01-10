{ pkgs, swww-upstream, ... }:
{
  imports = [
    ./gtk.nix
    ../../../home-manager/default.nix
    ../../../home-manager/hyprland.nix
    ../../../home-manager/waybar.nix
    ../../../home-manager/brave-torrent.nix
  ];

  home.packages = with pkgs; [
    nvtopPackages.full
    kdePackages.dolphin
    kdePackages.kio-extras
    cliphist
    melonDS
    grim
    rofi
    mako
    swww-upstream
    zathura
    image-roll
    pavucontrol
  ];

  braveTorrent.enable = true;

  programs.kitty = {
    themeFile = "spaceduck";
    font.name = "JetBrainsMono Nerd Font";
  };

  programs.helix.settings.theme = "base16_default";

  programs.zsh.oh-my-zsh.theme = "dst";

  xdg.mimeApps.defaultApplications = {
    "text/plain" = [ "helix.desktop" ];
    "application/pdf" = [ "zathura.desktop" ];
    "image/*" = [ "image-roll.desktop" ];
    "video/png" = [ "vlc.desktop" ];
    "video/jpg" = [ "vlc.desktop" ];
    "video/*" = [ "vlc.desktop" ];
  };

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.
}
