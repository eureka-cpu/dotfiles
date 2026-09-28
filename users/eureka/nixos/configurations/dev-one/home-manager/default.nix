{ pkgs, lib, ... }:
{
  imports = [
    ./gtk.nix
    ../../../../home-manager/hyprland.nix
    ../../../../home-manager/default.nix
  ];

  home.packages = with pkgs; [
    socat
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

  programs.kasane.palette = lib.mkForce "shibui-gamma";

  programs.kitty.font = {
    name = lib.mkForce "JetBrainsMono Nerd Font";
    size = lib.mkForce 13;
  };

  programs.helix.settings.theme = lib.mkForce "shibui-gamma";

  xdg.configFile."helix/themes/shibui-gamma.toml" = {
    source = "${pkgs.kasane}/themes/helix/shibui-gamma.toml";
    force = true;
  };

  home.stateVersion = "23.11";
}
