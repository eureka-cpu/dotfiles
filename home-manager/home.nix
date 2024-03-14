{ pkgs, inputs, ... }:

{
  imports = [
    ./gtk.nix
    inputs.nix-colors.homeManagerModules.default
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
    networkmanagerapplet
    wl-clipboard
    (brave.override {
      commandLineArgs = "--disable-gpu --enable-chrome-browser-cloud-management ";
    })
    kitty
    # pwvucontrol
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
    kitty-themes
    # simp1e-cursors
    zathura
    image-roll
    celluloid
    auto-cpufreq
    gnomeExtensions.pop-shell
    gnomeExtensions.color-picker
    gnomeExtensions.user-themes
    blender
    libreoffice
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
    theme = "Leaf Light";
    font = {
      name = "JetBrainsMono Nerd Font";
    };
    settings = {
      # The window padding (in pts) (blank area between the text and the window border).
      # A single value sets all four sides. Two values set the vertical and horizontal sides.
      # Three values set top, horizontal and bottom. Four values set top, right, bottom and left.
      window_padding_width = "8 0 8 8";
      hide_window_decorations = true;
    };
  };
  programs.helix = {
    enable = true;
    defaultEditor = true;
    settings = {
      theme = "base16_default";
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
          characeter = "╎";
          skip-levels = 1;
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

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  home.sessionVariables = {};

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
