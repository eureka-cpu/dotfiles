{ pkgs, ... }:
{
  # Sometimes switching configurations changes the desktop audio volume
  # so this script is for conveneince to reset the desktop volume to 100%.
  reset-desktop-volume = pkgs.writeShellScriptBin "reset-desktop-volume" ''
    /run/current-system/sw/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 1.0
  '';

  environment.systemPackages = [ reset-desktop-volume ];
}
