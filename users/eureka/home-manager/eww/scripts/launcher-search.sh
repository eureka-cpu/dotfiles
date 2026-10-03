#!/usr/bin/env sh
# Bound to the launcher input's :onchange. Filters apps by the current query
# and resets selection to the top match.
#
# Deliberately never writes launcher-query here. It's bound to the input's
# :value, and GTK already has the just-typed text in its own buffer; echoing
# it back means eww round-trips through a forked shell + the eww IPC socket
# (real latency, not just "slow" in theory) before reapplying :value, which
# resets the entry's cursor to the start of the text. Any gap at all lets
# further typing race ahead and then get stomped by the stale echo. So
# launcher-query is write-only from outside normal typing: it's only ever
# set (to "") by the reset paths in toggle-launcher.sh / launcher-nav.sh /
# the close button, to force the field clear on close.

query="$1"

if [ -z "$query" ]; then
  json="[]"
else
  json=$(sh ~/.config/eww/scripts/apps.sh "$query")
fi

eww update launcher-selected=0 filtered-apps-json="$json"
