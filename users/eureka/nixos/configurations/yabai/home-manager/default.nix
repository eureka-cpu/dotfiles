{ pkgs, nix-colors, ... }:
{
  imports = [
    ./gtk.nix
    ../../../../home-manager/hyprland.nix
    ../../../../home-manager/default.nix
    nix-colors.homeManagerModules.default
  ];

  home.packages = with pkgs; [
    networkmanagerapplet
    (brave.override {
      commandLineArgs = "--disable-gpu --enable-chrome-browser-cloud-management";
    })
    # code
    (vscode-with-extensions.override {
      vscodeExtensions = with vscode-extensions; [
        bbenoist.nix
        rust-lang.rust-analyzer
        vadimcn.vscode-lldb
        pkief.material-product-icons
        tamasfe.even-better-toml
        esbenp.prettier-vscode
        ms-vsliveshare.vsliveshare
        vscodevim.vim
        piousdeer.adwaita-theme
        dracula-theme.theme-dracula
        zhuangtongfa.material-theme
        file-icons.file-icons
        eamodio.gitlens
      ];
    })
    # studio
    v4l-utils
    playerctl
  ];

  programs.kitty = {
    themeFile = "GruvboxMaterialDarkMedium";
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 13;
    };
  };
  programs.helix.settings.theme = "gruvbox_material_dark_medium";

  home.stateVersion = "25.05";
}
