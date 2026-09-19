{ pkgs, ... }:
{
  imports = [
    ./gtk.nix
    ../../../../home-manager/default.nix
    ../../../../home-manager/brave-torrent.nix
    ../../../../home-manager/fastfetch.nix
    ../../../../home-manager/noctalia/noctalia.nix
  ];

  home.packages = with pkgs; [
    noctalia-shell
    polkit_gnome
    nautilus
     # comms
    telegram-desktop
    zoom-us
    discord
    # studio
    inkscape
    krita
    reaper
    melonds
    blender
    steam
    libreoffice
  ];

  braveTorrent.enable = true;

  xdg.configFile."niri/config.kdl".source = ./config.kdl;
  
  programs.kitty = {
    themeFile = "Catppuccin-Macchiato";
    font.name = "JetBrainsMono Nerd Font";
  };

  programs.helix.settings.theme = "catppuccin_macchiato";

  # zsh & oh-my-zsh configurations
  programs.zsh.oh-my-zsh.theme = "dst";

  # Fix for broken desktop entry. https://github.com/brave/brave-browser/issues/52193
  xdg.dataFile."applications/com.brave.Browser.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Brave Browser (hidden)
    NoDisplay=true
    Hidden=true
    ''; 

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.
}
