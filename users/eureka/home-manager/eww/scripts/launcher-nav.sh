#!/usr/bin/env sh
# Bound inside the Hyprland "launcher" submap (see hyprland.nix extraConfig),
# so these only fire while the eww launcher is open.
# Usage: launcher-nav.sh <escape|up|down|enter>

action="$1"

case "$action" in
  escape)
    eww close launcher
    eww update launcher-query="" launcher-selected=0 filtered-apps-json="[]"
    hyprctl dispatch submap reset
    ;;

  up|down)
    sel=$(eww get launcher-selected)
    count=$(eww get filtered-apps-json | grep -o '"rank"' | wc -l)
    if [ "$count" -gt 0 ]; then
      if [ "$action" = "up" ]; then
        sel=$((sel - 1))
        [ "$sel" -lt 0 ] && sel=0
      else
        sel=$((sel + 1))
        max=$((count - 1))
        [ "$sel" -gt "$max" ] && sel=$max
      fi
      eww update launcher-selected="$sel"
    fi
    ;;

  enter)
    sel=$(eww get launcher-selected)
    json=$(eww get filtered-apps-json)
    cmd=$(printf '%s' "$json" | awk -v want="$sel" '
      {
        n = split($0, items, "},{")
        for (i = 1; i <= n; i++) {
          item = items[i]
          if (match(item, /"rank":[0-9]+/)) {
            rankstr = substr(item, RSTART, RLENGTH)
            gsub(/[^0-9]/, "", rankstr)
            if (rankstr + 0 == want && match(item, /"onclick":"([^"\\]|\\.)*"/)) {
              field = substr(item, RSTART, RLENGTH)
              sub(/^"onclick":"/, "", field)
              sub(/"$/, "", field)
              gsub(/\\"/, "\"", field)
              gsub(/\\\\/, "\\", field)
              print field
            }
          }
        }
      }
    ')
    [ -n "$cmd" ] && eval "$cmd"
    hyprctl dispatch submap reset
    ;;
esac
