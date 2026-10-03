#!/usr/bin/env sh
# Bound to the launcher input's :onchange. Filters apps by the current query
# and resets selection to the top match.

query="$1"

if [ -z "$query" ]; then
  json="[]"
else
  json=$(sh ~/.config/eww/scripts/apps.sh "$query")
fi

eww update launcher-query="$query" launcher-selected=0 filtered-apps-json="$json"
