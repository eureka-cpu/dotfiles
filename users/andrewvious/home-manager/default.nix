{ pkgs, lib, helix-themes, user, ... }:

{
  home.username = user.name;
  home.homeDirectory = user.homeDirectory;

  home.packages = with pkgs; [
    home-manager
    obsidian
    wl-clipboard
    brave
    kitty
    # shell
    zsh
    oh-my-zsh
    neofetch
    # code
    docker
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
        ms-python.python
      ];
    })
    nil # nix lsp for Helix
    # studio
    obs-studio
    ffmpeg # video formatter
    v4l-utils
    gphoto2
    discord
    kitty-themes
    vlc
    spotify
  ];
  
  programs.kitty = {
    enable = true;
    theme = "kanagawabones";
    font.name = "JetBrainsMono Nerd Font";
    settings = {
      hide_window_decorations = true;
    };
  };

  programs.helix = {
    enable = true;
    defaultEditor = true;
    settings = {
      theme = "kanabox_default";
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
    languages = {
      language-server.buf = {
        command = "${pkgs.buf}/bin/buf";
        args = [ "beta" "lsp" ];
      };
      language = [{
        name = "protobuf";
        auto-format = true;
        language-servers = [ "buf" ];
      }];
    };
    themes = helix-themes.outputs.themes;
  };

  # zsh & oh-my-zsh configurations
  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion = {
        enable = true;
      };
      shellAliases = {
        swaydev = "nix develop github:fuellabs/fuel.nix#sway-dev -c zsh";
      };
      oh-my-zsh = {
        enable = true;
        plugins = [ "git" ];
        theme = "dst";
      };
    };

    git = {
      enable = true;
      userName = "andrewvious";
      userEmail = "ohbandrew@gmail.com";
    };

    # Let Home Manager install and manage itself.
    home-manager.enable = true;
  };
}
