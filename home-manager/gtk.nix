{ pkgs, ... }:

let
  cursor = pkgs.simp1e-cursors;
in
{
  gtk = {
    enable = true;
    theme.name = "gruvbox-dark";

    # Uncomment this once the icons gets merged
    # into nixpkgs
    # 
    # iconTheme = {
    #   name = "Gruvbox-Plus-Dark";
    #   package = pkgs.gruvbox-plus-icon-pack;
    # };
    cursorTheme = {
      size = 24;
      package = cursor;
      name = cursor.name;
    };
  };
}
