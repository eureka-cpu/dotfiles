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
#
# launcher-live-query mirrors the typed text for other scripts to read (e.g.
# launcher-nav.sh checking for a `nix search `/`nix run ` prefix on Enter).
# It isn't bound to the input's :value anywhere, so unlike launcher-query,
# writing to it every keystroke can't cause the GTK cursor-jump feedback
# loop - there's nothing reactively re-applying it to the entry widget.
#
# eww forks a new instance of this script on every keystroke, so with fast
# typing several instances are in flight at once, with no guarantee they
# finish (or even reach each `eww update` call) in keystroke order. Earlier
# attempts at this just reordered the writes to be "fast" (before apps.sh),
# which narrows the race but doesn't close it - two "fast" writes from two
# different instances can still land out of order under fast enough typing,
# confirmed by hand with synthetic typing. So instead, every instance
# registers itself in LOCKFILE as "the current one" and checks before each
# write whether it's since been superseded by a newer instance, abandoning
# silently if so. This makes the outcome always match the latest keystroke
# regardless of completion order, not just "usually" for realistic typing
# speed.

query="$1"
LOCKFILE="${XDG_RUNTIME_DIR:-/tmp}/eww-launcher-search.lock"
echo "$$" > "$LOCKFILE"

is_current() {
  [ "$(cat "$LOCKFILE" 2>/dev/null)" = "$$" ]
}

case "$query" in
  "nix search "*|"nix run "*) nixpending=true ;;
  *)                          nixpending=false ;;
esac

is_current || exit 0
eww update launcher-mode="apps" launcher-live-query="$query" launcher-nix-pending="$nixpending"

if [ "$nixpending" = true ]; then
  # Not a real app query - nothing would match, so skip apps.sh entirely.
  is_current || exit 0
  eww update launcher-selected=0 filtered-apps-json="[]"
  exit 0
fi

if [ -z "$query" ]; then
  json="[]"
else
  json=$(sh ~/.config/eww/scripts/apps.sh "$query")
fi

is_current || exit 0
eww update launcher-selected=0 filtered-apps-json="$json"
