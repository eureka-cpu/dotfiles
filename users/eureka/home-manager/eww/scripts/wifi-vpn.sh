#!/usr/bin/env sh
nmcli -t -f NAME,TYPE,STATE connection show 2>/dev/null \
  | grep -E ':vpn:|:wireguard:' \
  | awk -F: '{
      name=$1; state=$3; active=(state=="activated")?1:0
      gsub(/"/, "\\\"", name)
      if (active) {
        onclick=sprintf("nmcli con down '\''%s'\'' 2>/dev/null &", name)
        dot="●"; cls="vpn-dot-on"
      } else {
        onclick=sprintf("nmcli con up '\''%s'\'' 2>/dev/null &", name)
        dot="○"; cls="vpn-dot-off"
      }
      gsub(/"/, "\\\"", onclick)
      printf "{\"name\":\"%s\",\"onclick\":\"%s\",\"dot\":\"%s\",\"cls\":\"%s\"}\n", name, onclick, dot, cls
    }' \
  | paste -s -d, | awk '{print "[" $0 "]"}' | grep -v "^\[\]$" || echo "[]"
