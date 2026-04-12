{ pkgs, ... }:
{
  imports = [
    ./gtk.nix
    ../../../../home-manager/default.nix
  ];

  home.packages = with pkgs; [
    nvtopPackages.full
    # comms
    telegram-desktop
    signal-desktop
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
    tuxguitar
    v4l-utils
    davinci-resolve
    zathura
    image-roll
    celluloid
    blender
    libreoffice
  ];
  
  programs.kitty = {
    themeFile = "kanagawa";
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 15;
    };
  };
  programs.helix.settings.theme = "kanagawa";

  home.stateVersion = "23.05";
}
