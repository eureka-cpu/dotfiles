#!/usr/bin/env sh
# Usage: apps.sh <query>       -> JSON array of up to 8 matches (for the launcher UI)
#        apps.sh --warm        -> populate the icon cache for every installed app,
#                                  without printing anything (run once in the
#                                  background at eww startup, see toggle-launcher.sh)
#
# [{"rank":0,"name":"Firefox","icon":"/path/to/icon.svg","onclick":"<cmd> & disown; ..."}]
#
# Resolving an icon name to a file means walking the icon-theme directories with
# `find`, which is too slow to do synchronously on every keystroke (eww kills
# :onchange commands that run long, so a slow search just silently shows nothing).
# So resolved icon paths are cached in a flat file and only ever looked up by
# `find` once per icon name, ever.

query="$1"
US=$(printf '\037')
ICON_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/eww-launcher-icons.tsv"
mkdir -p "$(dirname "$ICON_CACHE")"
touch "$ICON_CACHE"

# Icon-theme aggregation on this system is sparse (most packages' icons never
# get symlinked into the shared hicolor tree), so look in the shared theme
# dirs first, then fall back to the icon shipped in the app's own package
# output (passed in as $2, the resolved store path root).
resolve_icon() {
  icon="$1"
  pkgroot="$2"
  case "$icon" in
    /*)
      [ -f "$icon" ] && printf '%s' "$icon"
      return
      ;;
  esac
  for root in \
    /run/current-system/sw/share/icons/Gruvbox-Plus-Dark \
    /etc/profiles/per-user/"$USER"/share/icons/Gruvbox-Plus-Dark \
    /run/current-system/sw/share/icons/hicolor \
    /etc/profiles/per-user/"$USER"/share/icons/hicolor \
    "$HOME/.local/share/icons/hicolor" \
    /run/current-system/sw/share/pixmaps
  do
    [ -d "$root" ] || continue
    found=$(find -L "$root/apps" \( -iname "$icon.svg" -o -iname "$icon.png" \) 2>/dev/null | head -1)
    [ -z "$found" ] && found=$(find -L "$root" \( -iname "$icon.svg" -o -iname "$icon.png" \) 2>/dev/null | head -1)
    [ -n "$found" ] && { printf '%s' "$found"; return; }
  done
  if [ -n "$pkgroot" ]; then
    found=$(find -L "$pkgroot/share/icons" "$pkgroot/share/pixmaps" \( -iname "$icon.svg" -o -iname "$icon.png" \) 2>/dev/null | head -1)
    [ -n "$found" ] && printf '%s' "$found"
  fi
}

# Cached, fast version of resolve_icon: everything above only ever runs once
# per icon name, ever (results, including "not found", are cached).
find_icon() {
  icon="$1"
  pkgroot="$2"
  [ -z "$icon" ] && return
  cached=$(awk -F'\t' -v k="$icon" '$1 == k { print $2; f = 1 } END { exit !f }' "$ICON_CACHE")
  if [ $? -eq 0 ]; then
    printf '%s' "$cached"
    return
  fi
  resolved=$(resolve_icon "$icon" "$pkgroot")
  printf '%s\t%s\n' "$icon" "$resolved" >> "$ICON_CACHE"
  printf '%s' "$resolved"
}

jesc() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

candidates=$(
  for dir in \
    /run/current-system/sw/share/applications \
    /etc/profiles/per-user/"$USER"/share/applications \
    "$HOME/.nix-profile/share/applications" \
    "$HOME/.local/share/applications"
  do
    [ -d "$dir" ] && find "$dir" -maxdepth 1 -name "*.desktop"
  done 2>/dev/null | xargs -r awk -v US="$US" '
    function emit(    bin0) {
      if (name == "" || execline == "" || skip) return
      gsub(/%[a-zA-Z]/, "", execline)
      gsub(/^[ \t]+|[ \t]+$/, "", execline)
      bin0 = execline
      sub(/[ \t].*/, "", bin0)
      cmd = term ? "kitty -e sh -c " shq(execline) : execline
      printf "%s%s%s%s%s%s%s\n", name, US, icon, US, cmd, US, bin0
    }
    function shq(s) {
      gsub(/'"'"'/, "'"'"'\\'"'"''"'"'", s)
      return "'"'"'" s "'"'"'"
    }
    FNR == 1 { emit(); name = ""; execline = ""; icon = ""; skip = 0; term = 0; insection = 0 }
    /^\[Desktop Entry\]/ { insection = 1; next }
    /^\[/ { insection = 0; next }
    !insection { next }
    /^Name=/ && name == "" { name = substr($0, 6) }
    /^Exec=/ && execline == "" { execline = substr($0, 6) }
    /^Icon=/ && icon == "" { icon = substr($0, 6) }
    /^NoDisplay=true/ { skip = 1 }
    /^Hidden=true/ { skip = 1 }
    /^Terminal=true/ { term = 1 }
    END { emit() }
  ' | sort -t"$US" -k1,1 -u
)

resolve_pkgroot() {
  bin0="$1"
  binpath=$(command -v "$bin0" 2>/dev/null)
  [ -z "$binpath" ] && return
  resolved=$(readlink -f "$binpath" 2>/dev/null)
  [ -n "$resolved" ] && dirname "$(dirname "$resolved")"
}

if [ "$query" = "--warm" ]; then
  printf '%s\n' "$candidates" | while IFS="$US" read -r name icon cmd bin0; do
    find_icon "$icon" "$(resolve_pkgroot "$bin0")" > /dev/null
  done
  exit 0
fi

matched=$(printf '%s\n' "$candidates" | awk -F"$US" -v q="$query" '
  BEGIN { q = tolower(q) }
  tolower($1) ~ q { print }
' | head -8)

[ -z "$matched" ] && { echo "[]"; exit 0; }

i=0
printf '%s\n' "$matched" | while IFS="$US" read -r name icon cmd bin0; do
  iconpath=$(find_icon "$icon" "$(resolve_pkgroot "$bin0")")
  launch="$cmd & disown; eww close launcher; eww update launcher-query=\"\" launcher-selected=0 filtered-apps-json=\"[]\"; hyprctl dispatch submap reset"
  printf '{"rank":%d,"name":"%s","icon":"%s","onclick":"%s"}\n' "$i" "$(jesc "$name")" "$(jesc "$iconpath")" "$(jesc "$launch")"
  i=$((i + 1))
done | paste -s -d, | awk '{print "[" $0 "]"}'
