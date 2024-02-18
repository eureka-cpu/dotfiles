{ pkgs, ... }:

{
  gtk = {
    enable = true;
    theme.name = "gruvbox-dark";

    iconTheme = {
      name = "Gruvbox-Plus-Dark";
      package = pkgs.gruvbox-plus-icons;
    };
  };
}
