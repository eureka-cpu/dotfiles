#!/usr/bin/env bash
# Arg: optional event string (e.g. "workspace>>2") or empty.
# For workspace switch events the ID is extracted directly; otherwise hyprctl is called.
if echo "$1" | grep -q '^workspace>>'; then
  ACTIVE=$(echo "$1" | sed 's/^workspace>>//')
else
  ACTIVE=$(hyprctl activeworkspace -j 2>/dev/null | grep -o '"id": *[0-9]*' | grep -o '[0-9]*')
fi
hyprctl workspaces -j 2>/dev/null | awk -v a="$ACTIVE" '
  /"id":/      { gsub(/[^0-9]/, "", $0); id = $0 + 0 }
  /"windows":/ { gsub(/[^0-9]/, "", $0); if ($0 + 0 > 0 && id != a + 0) printf ":%d", id }
  END          { print ":" }
'
