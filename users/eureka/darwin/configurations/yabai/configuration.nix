{ config, pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../../darwin/configuration.nix
  ];

  services.tailscale.enable = true;
  # The nix-darwin tailscale module only provisions /etc/resolver/ts.net, which
  # covers the default *.ts.net MagicDNS suffix. Our tailnet uses a custom
  # MagicDNS domain, so add a scoped resolver pointing at Tailscale's resolver
  # (100.100.100.100) for it — otherwise *.applicative.internal names (e.g. the
  # git forge) fail to resolve on macOS with headless tailscaled.
  environment.etc."resolver/applicative.internal".text = "nameserver 100.100.100.100";

  services.yabai = {
    enable = true;
    package = pkgs.yabai;
    enableScriptingAddition = true;
    config = {
      focus_follows_mouse = "autoraise";
      mouse_follows_focus = "off";
      window_placement = "second_child";
      window_opacity = "off";
      window_opacity_duration = "0.0";
      window_border = "on";
      window_border_placement = "inset";
      window_border_width = 2;
      window_border_radius = 3;
      active_window_border_topmost = "off";
      window_topmost = "on";
      window_shadow = "float";
      active_window_border_color = "0xff5c7e81";
      normal_window_border_color = "0xff505050";
      insert_window_border_color = "0xffd75f5f";
      active_window_opacity = "1.0";
      normal_window_opacity = "1.0";
      split_ratio = "0.50";
      auto_balance = "on";
      mouse_modifier = "fn";
      mouse_action1 = "move";
      mouse_action2 = "resize";
      layout = "bsp";
      top_padding = 10;
      bottom_padding = 10;
      left_padding = 10;
      right_padding = 10;
      window_gap = 10;
    };
    extraConfig = ''
      yabai -m rule --add app='System Preferences' manage=off
    '';
  };

  nix = {
    # Necessary for using `linux-builder`.
    settings.trusted-users = [ "root" "@admin" ];
    # Linux VM launchd service
    linux-builder = {
      enable = true;
      ephemeral = true;
      maxJobs = 4;
      config = {
        virtualisation = {
          darwin-builder = {
            diskSize = 40 * 1024;
            memorySize = 8 * 1024;
          };
          cores = 6;
        };
      };
    };
  };
}

