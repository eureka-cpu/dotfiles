{ pkgs, config, lib, ... }:
let
  hyprctlBin = "${pkgs.hyprland}/bin/hyprctl";
  kittyBin = "${pkgs.kitty}/bin/kitty";
  cmatrixBin = "${pkgs.cmatrix}/bin/cmatrix";
  awkBin = "${pkgs.gawk}/bin/awk";
  grepBin = "${pkgs.gnugrep}/bin/grep";
  sleepBin = "${pkgs.coreutils}/bin/sleep";
  pkillBin = "${pkgs.procps}/bin/pkill";
  brightnessctlBin = "${pkgs.brightnessctl}/bin/brightnessctl";
  hyprlock = "${pkgs.hyprlock}/bin/hyprlock";

  dimScreen = pkgs.writeShellScriptBin "dim-screen.sh" ''
    # Save current brightness and reduce to 1/3 of current value
    current=$(${brightnessctlBin} g)
    target=$(( current / 3 ))
    ${brightnessctlBin} -s set "$target"
  '';

  cmatrixSaver = pkgs.writeShellScriptBin "cmatrix-saver.sh" ''
    set -eu

    if pgrep -f "kitty.*--title=cmatrix-saver-" >/dev/null; then
      exit 0
    fi

    monitors="$(${hyprctlBin} monitors | ${awkBin} '/^Monitor /{print $2}')"

    for m in $monitors; do
      title="cmatrix-saver-$m"

      ${hyprctlBin} dispatch focusmonitor "$m" >/dev/null 2>&1 || true
      ${hyprctlBin} dispatch exec "${kittyBin} --title=$title ${cmatrixBin} -b" >/dev/null 2>&1

      ${sleepBin} 0.15
      ${hyprctlBin} dispatch fullscreenstate 2 2 >/dev/null 2>&1 || true
    done

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

  lockSaver = pkgs.writeShellScriptBin "lock-saver.sh" ''
    ${pkillBin} -f "kitty.*--title=cmatrix-saver-" || true
    ${hyprlock} &
  '';
in
{
  home.packages = with pkgs; [
    cmatrix
    hypridle
    brightnessctl
    dimScreen
    cmatrixSaver
    lockSaver
  ];

  systemd.user.services.hypridle = {
    Unit = {
      After = lib.mkForce [ "hyprland-session.target" ];
      PartOf = lib.mkForce [ "hyprland-session.target" ];
    };
    Install.WantedBy = lib.mkForce [ "hyprland-session.target" ];
  };

  services.hypridle = {
    enable = true;

    settings = {
      listener = [
        {
          # dim screen after 2min idle
          timeout = 120;
          on-timeout = "${dimScreen}/bin/dim-screen.sh";
          on-resume = "${brightnessctlBin} -r";
        }
        {
          # cmatrix screensaver after 5min idle
          timeout = 300;
          on-timeout = "${cmatrixSaver}/bin/cmatrix-saver.sh";
        }
        {
          # lock screen after 7min idle
          timeout = 420;
          on-timeout = "${lockSaver}/bin/lock-saver.sh";
        }
        {
          # dpms off after 10min idle
          timeout = 600;
          on-timeout = "${hyprctlBin} dispatch dpms off";
          on-resume = "${hyprctlBin} dispatch dpms on";
        }
      ];
    };
  };
}
