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
    shellIntegration = {
      mode = "no-cursor";
      enableZshIntegration = true;
    };
    settings = {
      # The window padding (in pts) (blank area between the text and the window border).
      # A single value sets all four sides. Two values set the vertical and horizontal sides.
      # Three values set top, horizontal and bottom. Four values set top, right, bottom and left.
      window_padding_width = "8 0 8 8"; # extra padding for oh-my-zsh dst theme
      hide_window_decorations = true;
      cursor_shape = "block";
    };
  };
  
  programs.helix = {
    enable = true;
    defaultEditor = true;
    settings = {
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
    };
  };
  programs.git = {
    enable = true;
    userName = "andrewvious";
    userEmail = "ohbandrew@gmail.com";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
