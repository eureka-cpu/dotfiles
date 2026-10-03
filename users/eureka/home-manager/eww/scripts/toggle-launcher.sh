#!/usr/bin/env sh
# Bound to SUPER (tap): opens the launcher (and enters its Hyprland submap
# for Escape/Up/Down/Return) if closed, or closes it (and resets the submap)
# if already open.

if eww active-windows 2>/dev/null | grep -q '^launcher:'; then
  eww close launcher
  eww update launcher-query="" launcher-selected=0 filtered-apps-json="[]"
  hyprctl dispatch submap reset
else
  screen=$(eww get monitor-name)
  eww open launcher --screen "$screen"
  hyprctl dispatch submap launcher
fi
