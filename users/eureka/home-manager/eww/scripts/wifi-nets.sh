#!/usr/bin/env sh
nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY device wifi list 2>/dev/null \
  | grep -v "^::" | sort -t: -k1,1r -k3,3rn \
  | awk -F: '$1=="*"{seen[$2]=1;next} !seen[$2]++ && $2!=""' | head -7 \
  | awk -F: 'NF>=3 && $2!="" {
      ssid=$2; sig=$3+0; sec=$4
      gsub(/"/, "\\\"", ssid)
      icon=(sig>=75)?"󰤨":(sig>=50)?"󰤥":(sig>=25)?"󰤢":"󰤟"
      lock=(sec!="--"&&sec!="")?"  󰌾":""
      printf "{\"ssid\":\"%s\",\"lock\":\"%s\",\"icon\":\"%s\",\"onclick\":\"nmcli dev wifi connect '\''%s'\'' 2>/dev/null &\"}\n", ssid, lock, icon, ssid
    }' \
  | paste -s -d, | awk '{print "[" $0 "]"}' | grep -v "^\[\]$" || echo "[]"
