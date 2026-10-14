{ pkgs, lib, config, ... }:
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
    socat
    # comms
    telegram-desktop
    # studio
    inkscape
    kdePackages.kdenlive
    krita
    reaper
    blender
    steam
    libreoffice
  ];

  programs.kasane.palette = lib.mkForce "shibui-gamma";

  programs.kitty.font = {
    name = lib.mkForce "JetBrainsMono Nerd Font";
    size = lib.mkForce 13;
  };

  programs.helix.settings.theme = lib.mkForce "shibui-gamma";

  xdg.configFile."helix/themes/shibui-gamma.toml" = {
    source = "${pkgs.kasane}/themes/helix/shibui-gamma.toml";
    force = true;
  };

  services.hyprpaper.settings =
    let wallpaper = "${config.home.homeDirectory}/Wallpapers/fuji.jpg";
    in {
      preload = [ wallpaper ];
      wallpaper = [{ monitor = ""; path = wallpaper; }];
    };

  # Ryzen 7 PRO 5850U, 64GB, CPU inference, so local is offline fallback only.
  # gemma4:26b (MoE) answered every scout test correctly in 3-4 min; the
  # qwen3:30b tag is the always-thinking 2507 build and was slower, and
  # models with ~1B active params ran 4x faster but invented answers.
  # Measured ~40 tok/s prefill, 8-12 tok/s generation. The Vega iGPU via
  # ollama-vulkan hits amdgpu compute ring timeouts; don't use it.
  eureka.ollama = {
    model = "gemma4:26b";
    extraModels = [ "qwen3:30b" "qwen2.5-coder:14b" ];
  };

  home.stateVersion = "23.11";
}
