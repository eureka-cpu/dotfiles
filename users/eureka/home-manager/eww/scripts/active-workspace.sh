#!/usr/bin/env bash
SOCK="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
CACHE="/tmp/eww-ws-occupied-cache"

ws_cache_refresh() {
  hyprctl workspaces -j 2>/dev/null | awk '
    /"id":/      { gsub(/[^0-9]/, "", $0); id = $0 + 0 }
    /"windows":/ { gsub(/[^0-9]/, "", $0); if ($0 + 0 > 0) printf ":%d", id }
    END          { print ":" }
  ' > "$CACHE"
}

ws_occupied_output() {
  local active="$1"
  local result
  result=$(cat "$CACHE" 2>/dev/null || echo ":")
  [ -n "$active" ] && result=$(echo "$result" | sed "s|:${active}:|:|")
  echo "$result" | tr -s ':'
}

# Connect to socket FIRST to avoid missing events during initial queries
exec 3< <(socat -u UNIX-CONNECT:"$SOCK" -)

INIT_WS=$(hyprctl activeworkspace -j 2>/dev/null | grep -o '"id": *[0-9]*' | grep -o '[0-9]*')
ws_cache_refresh
echo "${INIT_WS:-1}@$(ws_occupied_output "$INIT_WS")"

while IFS= read -r line <&3; do
  case "$line" in
    "workspace>>"*)
      ws="${line#workspace>>}"
      # Cache read only — no hyprctl, no eww update IPC, just a pipe write
      echo "${ws}@$(ws_occupied_output "$ws")"
      ;;
    "openwindow>>"* | "closewindow>>"* | "movewindow>>"* | "destroyworkspace>>"*)
      ws_cache_refresh
      ACTIVE=$(hyprctl activeworkspace -j 2>/dev/null | grep -o '"id": *[0-9]*' | grep -o '[0-9]*')
      echo "${ACTIVE:-1}@$(ws_occupied_output "$ACTIVE")"
      ;;
  esac
done
