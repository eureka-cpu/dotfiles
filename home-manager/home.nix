{ pkgs, ... }:

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
    grim
    eww-wayland
    rofi-wayland
    mako
    swww
    xfce.thunar
    networkmanagerapplet
    wl-clipboard
    brave
    kitty
    # shell
    zsh
    oh-my-zsh
    neofetch
    # comms
    discord
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
    gruvbox-dark-gtk
    kitty-themes
    simp1e-cursors
    zathura
    image-roll
    celluloid
    jetbrains-mono
  ];

  # home.configFile = {
  #   "hypr/start.sh".source = ./hypr/start.sh;
  #   "hypr/hyprland.conf".source = ./hypr/hyprland.conf;
  # };

  programs.kitty = {
    enable = true;
    theme = "Gruvbox Material Dark Medium";
    font.package = pkgs.jetbrains-mono;
    font.name = "JetBrains Mono";
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
    themes = {
    # TODO: create separate file for this
    # TODO: use nix-colors
    # TODO: fix inlay hint color
      gruvbox_material_dark_medium = 
        let
          bg0 = "#282828";
          bg1 = "#32302f";
          bg2 = "#32302f";
          bg3 = "#45403d";
          bg4 = "#45403d";
          bg_visual_yellow = "#4f422e";
                   
          fg0 = "#d4be98";
          red = "#ea6962";
          orange = "#e78a4e";
          yellow = "#d8a657";
          green = "#a9b665";
          aqua = "#89b482";
          blue = "#7daea3";
          purple = "#d3869b";
          
          grey0 = "#7c6f64";
          grey2 = "#a89984";
        in {     
          "type" = yellow;
          "constant" = purple;
          "constant.numeric" = purple;
          "constant.character.escape" = orange;
          "string" = green;
          "string.regexp" = blue;
          "comment" = grey0;
          "variable" = fg0;
          "variable.builtin" = blue;
          "variable.parameter" = fg0;
          "variable.other.member" = fg0;
          "label" = aqua;
          "punctuation" = grey2;
          "punctuation.delimiter" = grey2;
          "punctuation.bracket" = fg0;
          "keyword" = red;
          "keyword.directive" = aqua;
          "operator" = orange;
          "function" = green;
          "function.builtin" = blue;
          "function.macro" = aqua;
          "tag" = yellow;
          "namespace" = aqua;
          "attribute" = aqua;
          "constructor" = yellow;
          "module" = blue;
          "special" = orange;
          
          "markup.heading.marker" = grey2;
          "markup.heading.1" = { fg = red; modifiers = [ "bold" ]; };
          "markup.heading.2" = { fg = orange; modifiers = [ "bold" ]; };
          "markup.heading.3" = { fg = yellow; modifiers = [ "bold" ]; };
          "markup.heading.4" = { fg = green; modifiers = [ "bold" ]; };
          "markup.heading.5" = { fg = blue; modifiers = [ "bold" ]; };
          "markup.heading.6" = { fg = fg0; modifiers = [ "bold" ]; };
          "markup.list" = red;
          "markup.bold" = { modifiers = [ "bold" ]; };
          "markup.italic" = { modifiers = [ "italic" ]; };
          "markup.link.url" = { fg = blue; modifiers = [ "underlined" ]; };
          "markup.link.text" = purple;
          "markup.quote" = grey2;
          "markup.raw" = green;
          
          "diff.plus" = green;
          "diff.delta" = orange;
          "diff.minus" = red;
          
          "ui.background" = { bg = bg0; };
          "ui.background.separator" = grey0;
          "ui.cursor" = { fg = bg0; bg = fg0; };
          "ui.cursor.match" = { fg = orange; bg = bg_visual_yellow; };
          "ui.cursor.insert" = { fg = bg0; bg = grey2; };
          "ui.cursor.select" = { fg = bg0; bg = blue; };
          "ui.cursorline.primary" = { bg = bg1; };
          "ui.cursorline.secondary" = { bg = bg1; };
          "ui.selection" = { bg = bg3; };
          "ui.linenr" = grey0;
          "ui.linenr.selected" = fg0;
          "ui.statusline" = { fg = fg0; bg = bg3; };
          "ui.statusline.inactive" = { fg = grey0; bg = bg1; };
          "ui.statusline.normal" = { fg = bg0; bg = fg0; modifiers = [ "bold" ]; };
          "ui.statusline.insert" = { fg = bg0; bg = yellow; modifiers = [ "bold" ]; };
          "ui.statusline.select" = { fg = bg0; bg = blue; modifiers = [ "bold" ]; };
          "ui.bufferline" = { fg = grey0; bg = bg1; };
          "ui.bufferline.active" = { fg = fg0; bg = bg3; modifiers = [ "bold" ]; };
          "ui.popup" = { fg = grey2; bg = bg2; };
          "ui.window" = { fg = grey0; bg = bg0; };
          "ui.help" = { fg = fg0; bg = bg2; };
          "ui.text" = fg0;
          "ui.text.focus" = fg0;
          "ui.menu" = { fg = fg0; bg = bg3; };
          "ui.menu.selected" = { fg = bg0; bg = blue; modifiers = [ "bold" ]; };
          "ui.virtual.whitespace" = { fg = bg4; };
          "ui.virtual.indent-guide" = { fg = bg4; };
          "ui.virtual.ruler" = { bg = bg3; };
          
          "hint" = blue;
          "info" = aqua;
          "warning" = yellow;
          "error" = red;
          "diagnostic" = { underline = { style = "curl"; }; };
          "diagnostic.hint" = { underline = { color = blue; style = "dotted"; }; };
          "diagnostic.info" = { underline = { color = aqua; style = "dotted"; }; };
          "diagnostic.warning" = { underline = { color = yellow; style = "curl"; }; };
          "diagnostic.error" = { underline = { color = red; style = "curl"; }; };
        };
     };
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
