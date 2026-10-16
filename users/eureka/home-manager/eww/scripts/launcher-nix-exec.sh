#!/usr/bin/env sh
# Run from launcher-nav.sh's `enter` action when the launcher query is
# literally `nix search ...` or `nix run ...`. Runs that exact text as a
# shell command and streams its combined stdout/stderr into launcher-output
# as it arrives, switching the launcher's output pane on to show it.
#
# eww's deflisten can't be used for this: it treats each line a listened
# process prints as a full replacement of the variable's value, so a
# process that emits real multi-line output can't be streamed into a single
# growing value that way. Instead this accumulates the raw output itself
# (via a scratch file, capped to the last MAX_LINES) and pushes it via
# `eww update` every UPDATE_EVERY lines. Both caps matter: nix evaluation
# can be very chatty (easily thousands of lines), and pushing the whole
# buffer on every single line is unbounded growth that eventually overflows
# the OS argument list limit for the `eww update` call (confirmed by hand:
# an uncapped version of this script hit "Argument list too long" and hung
# retrying until killed). The final state is always pushed once the command
# finishes, regardless of where the throttle counter was.
#
# Run via `script`, not a plain pipe: most CLIs (including nix, and whatever
# `nix run` launches) disable color output as soon as stdout isn't a tty.
# `script` gives the command a real pty so it colors its output normally,
# and we still capture that output byte-for-byte since script mirrors it to
# our pipe. The captured ANSI escapes are then converted to Pango markup
# with `ansifilter -M -f` (-f = fragment, no wrapping <span>) each time we
# push an update, since the GTK label displays Pango markup, not raw ANSI.
# Converting the whole capped buffer each time (not just new lines) keeps
# the markup well-formed even if a color was turned on before the point
# where old lines got dropped off the cap.
#
# `nix search` always leaves the launcher open, there's no real "success" to
# close on. `nix run` closes the launcher on exit 0, same as launching any
# other app, but stays open on failure so the error output is visible.

query="$1"

case "$query" in
  "nix search "*) subcmd=search ;;
  "nix run "*)    subcmd=run ;;
  *) exit 0 ;;
esac

MAX_LINES=300
UPDATE_EVERY=5

eww update launcher-mode="output" launcher-output=""

buf=$(mktemp)
trap 'rm -f "$buf"' EXIT

push_output() {
  tail -n "$MAX_LINES" "$buf" | ansifilter -M -f
}

{ script -qec "$query" /dev/null 2>&1; printf '__launcher_exit:%s\n' "$?"; } | {
  exitcode=0
  n=0
  while IFS= read -r line; do
    line=${line%$(printf '\r')}
    case "$line" in
      __launcher_exit:*)
        exitcode=${line#__launcher_exit:}
        ;;
      *)
        printf '%s\n' "$line" >> "$buf"
        n=$((n + 1))
        if [ $((n % UPDATE_EVERY)) -eq 0 ]; then
          eww update launcher-output="$(push_output)"
        fi
        ;;
    esac
  done
  eww update launcher-output="$(push_output)"

  if [ "$subcmd" = "run" ] && [ "$exitcode" = "0" ]; then
    eww close launcher
    eww update launcher-query="" launcher-live-query="" launcher-nix-pending="false" launcher-selected=0 filtered-apps-json="[]" launcher-mode="apps" launcher-output=""
    hyprctl dispatch submap reset
  fi
}
