{ pkgs, ... }:
{
  imports = [
    ../../../../home-manager/default.nix
    # ../../../../home-manager/sway.nix
  ];

  home.packages = with pkgs; [
    # wofi
    # mako
    # swaybg
    # nautilus
  ];

  programs.kitty = {
    themeFile = "rose-pine";
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 14;
    };
  };

  programs.helix.settings.theme = "rose_pine";

  # Snapdragon X Elite, 32GB, CPU-only: same reasoning as dev-one; offline
  # fallback only.
  eureka.ollama.model = "gemma4:26b";

  home.stateVersion = "25.05";
}
