{ pkgs, ... }:

let
  gruvbox-plus = import ./icon-themes/gruvbox-plus.nix { inherit pkgs; };
in
{
  gtk = {
    enable = true;
    theme.name = "gruvbox-dark-gtk";
    # cursorTheme.name = "sim1le-cursors"
    iconTheme = {
      name = gruvbox-plus.name;
      package = gruvbox-plus;
    };
  };
}
