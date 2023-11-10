{ /* pkgs, */... }:

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
  };
}
