{ pkgs, ... }:
{
  imports = [
    ./gtk.nix
    ../../../../home-manager/hyprland.nix
    ../../../../home-manager/default.nix
    ../../../../home-manager/hypridle.nix
    ../../../../home-manager/hyprpaper.nix
    ../../../../home-manager/hyprlock.nix
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

  # M1 16GB under Asahi, CPU inference: 8B is the most that leaves room for
  # the desktop; offline fallback only.
  eureka.ollama.model = "qwen3:8b";

  home.stateVersion = "25.05";
}
