{ pkgs, lib, ... }:
{
  imports = [
    ../../../../home-manager/default.nix
  ];

  programs.kitty = {
    themeFile = "ferra";
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 17;
    };
  };
  programs.helix.settings.theme = "ferra";

  # M1 16GB (Metal): an 8B model + 32K q8_0 KV cache stays inside the ~10.7GB
  # GPU budget; offline fallback only.
  eureka.ollama = {
    model = "qwen3:8b";
    quantizeKvCache = true;
  };

  home.stateVersion = "25.05";
}
