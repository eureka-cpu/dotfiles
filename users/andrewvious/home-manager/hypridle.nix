{ config, pkgs, ... }:
let
  hyprctlBin = "${pkgs.hyprland}/bin/hyprctl";
  kittyBin = "${pkgs.kitty}/bin/kitty";
  cmatrixBin = "${pkgs.cmatrix}/bin/cmatrix";
  awkBin = "${pkgs.gawk}/bin/awk";
  grepBin = "${pkgs.gnugrep}/bin/grep";
  sleepBin = "${pkgs.coreutils}/bin/sleep";
  pkillBin = "${pkgs.procps}/bin/pkill";

  cmatrixSaver = pkgs.writeShellScriptBin "cmatrix-saver.sh" ''
    set -eu

    # Avoid duplicates
    if pgrep -f "kitty.*--title=cmatrix-saver-" >/dev/null; then
      exit 0
    fi
  
    monitors="$(${hyprctlBin} monitors | ${awkBin} '/^Monitor /{print $2}')"
  
    for m in $monitors; do
      title="cmatrix-saver-$m"
  
      # Focus that monitor so the next window spawns there
      ${hyprctlBin} dispatch focusmonitor "$m" >/dev/null 2>&1 || true
  
      # Spawn kitty on the focused monitor
      ${hyprctlBin} dispatch exec "${kittyBin} --title=$title ${cmatrixBin} -b" >/dev/null 2>&1
  
      # Small delay so the new kitty becomes the active window
      ${sleepBin} 0.15
  
      # Fullscreen the active window on that monitor
      ${hyprctlBin} dispatch fullscreenstate 2 2 >/dev/null 2>&1 || true
    done
  
    # Record cursor position and exit when it changes
    ${sleepBin} 0.1
    last="$(${hyprctlBin} cursorpos 2>/dev/null | tr -d '\n' || true)"
    [ -n "$last" ] || exit 0
  
    while true; do
      ${sleepBin} 0.1
      now="$(${hyprctlBin} cursorpos 2>/dev/null | tr -d '\n' || true)"
      if [ -n "$now" ] && [ "$now" != "$last" ]; then
        ${pkillBin} -f "kitty.*--title=cmatrix-saver-" || true
        exit 0
      fi
    done
  '';
in
{
  home.packages = with pkgs; [
    cmatrix
    hypridle
    cmatrixSaver
  ];

  services.hypridle = {
    enable = true;

    settings = {
      listener = [
        {
          # start screensaver after 5min idle
          timeout = 300;
          on-timeout = "${cmatrixSaver}/bin/cmatrix-saver.sh";
        }
      ];
    };
  };
}
  
