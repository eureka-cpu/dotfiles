{ pkgs, inputs, ... }:

{
  imports = [
    ./gtk.nix
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "eureka";
  home.homeDirectory = "/home/eureka";

  home.packages = with pkgs; [
    home-manager
    nvtop
    # Hyprland
    grim
    eww-wayland
    rofi-wayland
    mako
    swww
    xfce.thunar
    wl-clipboard
    brave
    kitty
    # shell
    zsh
    oh-my-zsh
    neofetch
    # comms
    telegram-desktop
    # code
    git
    helix
    (vscode-with-extensions.override {
      vscodeExtensions = with vscode-extensions; [
        bbenoist.nix # nix syntax highlighting
        matklad.rust-analyzer
        vadimcn.vscode-lldb # lldb for rust
        pkief.material-product-icons
        tamasfe.even-better-toml
        esbenp.prettier-vscode
        ms-vsliveshare.vsliveshare
        vscodevim.vim
        piousdeer.adwaita-theme
        dracula-theme.theme-dracula
        zhuangtongfa.material-theme
        file-icons.file-icons
        eamodio.gitlens # git lens
      ];
    })
    nil
    rust-analyzer
    # studio
    obs-studio
    ffmpeg # video formatter
    v4l-utils
    gphoto2
    linuxKernel.packages.linux_6_1.v4l2loopback
    kitty-themes
    zathura
    image-roll
    celluloid
  ];

  xdg.configFile = {
    "hypr" = {
      source = ./hypr;
      recursive = true;
    };
    "rofi" = {
      source = ./rofi;
      recursive = true;
    };
  };

  programs.kitty = {
    enable = true;
    theme = "Gruvbox Material Dark Medium";
    font.name = "JetBrainsMono Nerd Font";
  };
  programs.helix = {
    enable = true;
    defaultEditor = true;
    settings = {
      theme = "gruvbox_material_dark_medium";
      editor = {
        cursor-shape = {
          insert = "underline";
          normal = "block";
          select = "block";
        };
        statusline = {
          mode = {
            insert = "INSERT";
            normal = "NORMAL";
            select = "SELECT";
          };
        };
        indent-guides = {
          render = true;
          characeter = "|";
        };
        lsp = {
          display-messages = true;
          display-inlay-hints = true;
        };
      };
    };
    themes = inputs.helix-themes.outputs.themes;
  };

  # zsh & oh-my-zsh configurations
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    shellAliases = {
      swaydev = "nix develop github:fuellabs/fuel.nix#sway-dev -c zsh";
    };
  };
  programs.zsh.oh-my-zsh = {
    enable = true;
    plugins = [ "git" ];
    theme = "dst";
  };

  programs.git = {
    enable = true;
    userName = "eureka-cpu";
    userEmail = "github.eureka@gmail.com";
  };

  xdg.mimeApps.defaultApplications = {
    "text/plain" = [ "helix.desktop" ];
    "application/pdf" = [ "zathura.desktop" ];
    "image/*" = [ "image-roll.desktop" ];
    "video/png" = [ "celluloid.desktop" ];
    "video/jpg" = [ "celluloid.desktop" ];
    "video/*" = [ "celluloid.desktop" ];
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.05"; # Please read the comment before changing.
}
