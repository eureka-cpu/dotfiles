function emit(    s) {
    s = active "@" occupied(active)
    if (s != last_out) {
        print s; fflush()
        last_out = s
    }
}

BEGIN {
    cmd = "hyprctl activeworkspace -j 2>/dev/null"
    while ((cmd | getline ln) > 0) {
        if (ln ~ /^ *"id":/) {
            match(ln, /[0-9]+/)
            active = substr(ln, RSTART, RLENGTH)
        }
    }
    close(cmd)
    if (active == "") active = "1"

    cmd = "hyprctl clients -j 2>/dev/null"
    in_ws = 0; cur_addr = ""
    while ((cmd | getline ln) > 0) {
        if (ln ~ /"address":/) {
            match(ln, /0x[0-9a-fA-F]+/)
            # Strip 0x prefix to match socket2 event address format
            cur_addr = RSTART ? substr(ln, RSTART+2, RLENGTH-2) : ""
        }
        if (ln ~ /"workspace": *\{/) in_ws = 1
        if (in_ws && ln ~ /^ *"id":/) {
            match(ln, /[0-9]+/)
            wsid = substr(ln, RSTART, RLENGTH) + 0
            if (cur_addr != "" && wsid > 0) {
                win_ws[cur_addr] = wsid
                wins[wsid]++
            }
            in_ws = 0
        }
    }
    close(cmd)
    emit()
}

/^workspace>>/ {
    active = substr($0, 12)
    emit()
    next
}

/^openwindow>>/ {
    split(substr($0, 13), f, ",")
    addr = f[1]; wsid = f[2] + 0
    if (wsid > 0) { wins[wsid]++; win_ws[addr] = wsid }
    emit()
    next
}

/^closewindow>>/ {
    addr = substr($0, 14)
    old = win_ws[addr] + 0
    if (old > 0) { if (--wins[old] <= 0) delete wins[old] }
    delete win_ws[addr]
    emit()
    next
}

/^movewindow>>/ {
    split(substr($0, 13), f, ",")
    addr = f[1]; new_ws = f[2] + 0
    old = win_ws[addr] + 0
    if (old > 0) { if (--wins[old] <= 0) delete wins[old] }
    if (new_ws > 0) { wins[new_ws]++; win_ws[addr] = new_ws }
    emit()
    next
}

/^destroyworkspace>>/ {
    wsid = substr($0, 19) + 0
    delete wins[wsid]
    emit()
    next
}

function occupied(act,    result, i) {
    result = ""
    for (i in wins)
        if (wins[i] > 0 && i + 0 != act + 0) result = result ":" i
    return (result == "") ? "::" : result ":"
}
