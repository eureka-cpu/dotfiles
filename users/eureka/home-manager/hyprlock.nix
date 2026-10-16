{ config, ... }:
let
  inherit (config.programs.kasane.colors)
    background black-bright blue foreground red;
  inherit (config.home) homeDirectory;
  hex = s: builtins.substring 1 (builtins.stringLength s - 1) s;
  wallpaper = "${homeDirectory}/Wallpapers/koi-rain.jpg";
in
{
  programs.hyprlock = {
    enable = true;

    settings = {
      general = {
        grace = 0;
        hide_cursor = true;
      };

      background = [{
        path = wallpaper;
        blur_passes = 3;
        blur_size = 7;
        brightness = 0.5;
      }];

      label = [{
        monitor = "";
        text = ''cmd[update:1000] date +"%H:%M"'';
        font_family = "JetBrainsMono Nerd Font";
        font_size = 72;
        color = "rgb(${hex foreground})";
        position = "0, 120";
        halign = "center";
        valign = "center";
      }];

      "input-field" = [{
        monitor = "";
        size = "320, 52";
        outline_thickness = 1;
        outer_color = "rgb(${hex black-bright})";
        inner_color = "rgb(${hex background})";
        font_color = "rgb(${hex foreground})";
        check_color = "rgb(${hex blue})";
        fail_color = "rgb(${hex red})";
        fade_on_empty = true;
        placeholder_text = "";
        position = "0, -80";
        halign = "center";
        valign = "center";
        rounding = 0;
      }];
    };
  };
}
