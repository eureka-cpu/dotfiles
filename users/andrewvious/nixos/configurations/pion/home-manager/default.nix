{ pkgs, ... }: {
  home.packages = with pkgs; [
    helix
    jellyfin
    yazi
    zellij
  ];
  # zsh configurations
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
  };

  home.stateVersion = "25.05";
}
