#!/usr/bin/env bash
# One sway IPC listener for both bars (started from the sway config):
#   workspace focus change -> new Anki + Latin word        (waybar signal 11)
#   binding mode change    -> show/hide the Super+b hints   (waybar signal 12)
# Reconnects if sway's IPC socket goes away.
FLAG=${XDG_RUNTIME_DIR:-/tmp}/waybar-barmode
rm -f "$FLAG"
while true; do
    swaymsg -t subscribe -m '["workspace","mode"]' 2>/dev/null |
        jq --unbuffered -r 'if has("current") then (if .change == "focus" then "ws" else empty end)
                            else "mode " + .change end' |
        while read -r kind name; do
            if [[ $kind == ws ]]; then
                pkill -RTMIN+11 -x waybar
            else
                if [[ $name == default ]]; then rm -f "$FLAG"; else : > "$FLAG"; fi
                pkill -RTMIN+12 -x waybar
            fi
        done
    sleep 2
done
