{ lib, ... }:
{
  services.hyprpaper = {
    enable = true;
    settings.splash = false;
  };
  systemd.user.services.hyprpaper = {
    Unit = {
      After = lib.mkForce [ "hyprland-session.target" ];
      PartOf = lib.mkForce [ "hyprland-session.target" ];
    };
    Install.WantedBy = lib.mkForce [ "hyprland-session.target" ];
  };
}
