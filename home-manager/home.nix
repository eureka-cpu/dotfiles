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
    # Hyprland
    # grim
    eww-wayland
    # rofi-wayland
    # mako
    # swww
    # xfce.thunar
    # networkmanagerapplet
    wl-clipboard
    brave
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
    #    fix kernel header vvvvvvvvvv
    # linuxKernel.packages.linux_5_15.vrl2loopbacko
    kitty-themes
    # simp1e-cursors
    # zathura
    # image-roll
    # celluloid
    auto-cpufreq
    gnomeExtensions.pop-shell
    gnomeExtensions.color-picker
    gnomeExtensions.user-themes
    blender
    libreoffice
  ];
  
  # xdg.configFile = {
  #   "hypr" = {
  #     source = ./hypr;
  #     recursive = true;
  #   };
  #   "rofi" = {
  #     source = ./rofi;
  #     recursive = true;
  #   };
  # };

  programs.kitty = {
    enable = true;
    theme = "Gruvbox Material Dark Medium";
    font.name = "JetBrainsMono Nerd Font";
    settings = {
      hide_window_decorations = true;
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

  dconf.settings = {
    # shell extensions
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "pop-shell@system76.com"
        "user-theme@gnome-shell-extensions.gcampax.github.com"
      ];
    };
    "org/gnome/shell/extensions/user-theme" = {
      name = "gruvbox-dark";
    };

    # keybindings
    "org/gnome/shell/keybindings" = {
      toggle-quick-settings = []; # turn off focus power menu
      toggle-message-tray = ["<Super>n"];
      focus-active-notification = [];
    };
    "org/gnome/desktop/wm/keybindings" = {
      close = ["<Super>q"];
      minimize = [];
      maximize = [];
      toggle-maximized = ["<Super>m"];
      # workspace/monitor settings
      switch-to-workspace-left = ["<Alt>h"];
      switch-to-workspace-right = ["<Alt>l"];
      move-to-workspace-left = ["<Shift><Alt>h"];
      move-to-workspace-right = ["<Shift><Alt>l"];
      move-to-monitor-down = [];  # handled by pop-shell
      move-to-monitor-left = [];  #
      move-to-monitor-right = []; #
      move-to-monitor-up = [];    #
    };
    "org/gnome/settings-daemon/plugins/media-keys" = {
      screensaver = []; # turn off lock screen
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

  # xdg.mimeApps.defaultApplications = {
  #   "text/plain" = [ "helix.desktop" ];
  #   "application/pdf" = [ "zathura.desktop" ];
  #   "image/*" = [ "image-roll.desktop" ];
  #   "video/png" = [ "celluloid.desktop" ];
  #   "video/jpg" = [ "celluloid.desktop" ];
  #   "video/*" = [ "celluloid.desktop" ];
  # };

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

  home.sessionVariables = {
    GTK_THEME = "gruvbox-dark";
    # XCURSOR_SIZE = "20";
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
