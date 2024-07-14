{ pkgs, nix-colors, helix-themes, user, ... }:
{
  imports = [
    ./gtk.nix
    ./hypr.nix
    nix-colors.homeManagerModules.default
  ];

  # Home Manager needs a bit of information about you and the paths it should manage.
  home.username = user.name;
  home.homeDirectory = user.homeDirectory;

  home.packages = with pkgs; [
    home-manager
    nvtopPackages.full
    # Hyprland
    grim
    eww
    rofi-wayland
    mako
    swww
    xfce.thunar
    wl-clipboard
    # TODO: override to always use the latest version
    brave
    kitty
    # shell
    zsh
    oh-my-zsh
    pfetch
    # comms
    telegram-desktop
    # code
    git
    helix
    (vscode-with-extensions.override {
      vscodeExtensions = with vscode-extensions; [
        bbenoist.nix # nix syntax highlighting
        rust-lang.rust-analyzer
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
    docker
    # studio
    obs-studio
    ffmpeg # video formatter
    gphoto2
    kitty-themes
    zathura
    image-roll
    celluloid
  ];

  programs.kitty = {
    enable = true;
    theme = "Gruvbox Material Dark Medium";
    font.name = "JetBrainsMono Nerd Font";
    settings = {
      # The window padding (in pts) (blank area between the text and the window border).
      # A single value sets all four sides. Two values set the vertical and horizontal sides.
      # Three values set top, horizontal and bottom. Four values set top, right, bottom and left.
      window_padding_width = "8 0 8 8";
    };
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
          character = "|";
          skip-levels = 1;
        };
        lsp = {
          display-messages = true;
          display-inlay-hints = true;
        };
      };
    };
    themes = helix-themes.outputs.themes;
  };

  # zsh & oh-my-zsh configurations
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "dst";
    };
  };
  programs.git = {
    enable = true;
    userName = "eureka-cpu";
    userEmail = "github.eureka@gmail.com";
  };

  xdg = {
    configFile = {
      rofi = {
        source = ./rofi;
        recursive = true;
      };
    };
    mimeApps.defaultApplications = {
      "text/plain" = [ "helix.desktop" ];
      "application/pdf" = [ "zathura.desktop" ];
      "image/*" = [ "image-roll.desktop" ];
      "video/png" = [ "celluloid.desktop" ];
      "video/jpg" = [ "celluloid.desktop" ];
      "video/*" = [ "celluloid.desktop" ];
    };
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
