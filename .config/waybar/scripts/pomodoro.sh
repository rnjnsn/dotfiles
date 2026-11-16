#!/usr/bin/env bash
# Waybar pomodoro timer: a single 25-minute countdown.
#   pomodoro.sh          -> print status JSON (called by waybar every second)
#   pomodoro.sh toggle   -> start a countdown, or stop the running one
# When the countdown hits zero it sends one notification and then stays
# at 00:00 until you click to start again.
# State file holds: "<phase> <start_epoch>"  (phase: idle | work | done)

WORK=$((25 * 60))
STATE="${XDG_CACHE_HOME:-$HOME/.cache}/waybar_pomodoro"
TOMATO="<span font_family='Noto Color Emoji'>🍅</span>"
now=$(date +%s)

read -r phase start _ 2>/dev/null < "$STATE"
phase=${phase:-idle}; start=${start:-0}

save() { printf '%s %s\n' "$1" "$2" > "$STATE"; }
refresh() { pkill -RTMIN+10 waybar 2>/dev/null || true; }

if [[ $1 == toggle ]]; then
    if [[ $phase == work ]]; then save idle 0; else save work "$now"; fi
    refresh; exit 0
fi

if [[ $phase == work ]]; then
    left=$(( WORK - (now - start) ))
    if (( left <= 0 )); then
        save done 0
        notify-send -a Pomodoro -u critical "Pomodoro" "25 minutes are up."
        phase=done
    fi
fi

case $phase in
    work) printf '{"text": "%s %02d:%02d", "class": "work", "tooltip": "Click: stop"}\n' \
              "$TOMATO" $((left / 60)) $((left % 60)) ;;
    done) printf '{"text": "%s 00:00", "class": "done", "tooltip": "Time is up. Click: start again"}\n' "$TOMATO" ;;
    *)    printf '{"text": "%s --:--", "class": "idle", "tooltip": "Click: start 25 min"}\n' "$TOMATO" ;;
esac
