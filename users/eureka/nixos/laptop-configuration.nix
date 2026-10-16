{ pkgs, ... }:
{
  # Enable power management.
  services = {
    auto-cpufreq.enable = true;
    tlp.enable = true;
    power-profiles-daemon.enable = false;
  };

  # Reduce brightness when unplugging AC (firmware handles the increase when plugging in)
  services.udev.extraRules = ''
    SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="0", \
      RUN+="${pkgs.writeShellScript "dim-on-battery" ''
        for bl in /sys/class/backlight/*/brightness; do
          max=$(cat "$(dirname "$bl")/max_brightness" 2>/dev/null) || continue
          cur=$(cat "$bl" 2>/dev/null) || continue
          thresh=$(( max * 30 / 100 ))
          [ "$cur" -gt "$thresh" ] && echo "$thresh" > "$bl"
        done
      ''}"
  '';
}
