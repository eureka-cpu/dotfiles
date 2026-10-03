{ lib, ... }:
{
  options.programs.eww.monitorDescription = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    example = "HP Inc. HP Z32 CN42411R5T";
    description = ''
      The Hyprland monitor description (as reported by `hyprctl monitors`)
      that the eww topbar should always open on for this machine.

      Hyprland identifies monitors by this description because it stays
      stable across cable/port changes, while the live output name (e.g.
      "DP-2") and its enumeration index do not. eww only accepts the output
      name, so that name is resolved from this description at daemon start.

      Leave null to let eww open on its default monitor.
    '';
  };

  options.programs.eww.batteryName = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = "BATT";
    example = "BAT0";
    description = ''
      The power supply name (as under /sys/class/power_supply and as
      reported by EWW_BATTERY) that the eww topbar's battery widget should
      read from. Leave null on machines with no battery to disable the
      widget entirely.
    '';
  };
}
