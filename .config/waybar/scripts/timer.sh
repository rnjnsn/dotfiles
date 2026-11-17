#!/usr/bin/env bash
# Waybar focus timer: one countdown, 25 or 50 minutes.
#   timer.sh            -> status JSON (waybar calls this every second)
#   timer.sh toggle     -> start, or stop the running countdown   (left click)
#   timer.sh length     -> switch 25 <-> 50 min                    (right click)
#                          (also applies to a countdown that is already running)
# When time is up: one notification, then it shows "done" until you click.
# State file: "<phase> <start_epoch> <minutes>"   phase: idle | run | done

STATE="${XDG_CACHE_HOME:-$HOME/.cache}/waybar_timer"
now=$EPOCHSECONDS

read -r phase start mins _ 2>/dev/null < "$STATE"
phase=${phase:-idle}; start=${start:-0}; mins=${mins:-25}

save() { printf '%s %s %s\n' "$1" "$2" "$3" > "$STATE"; }
refresh() { pkill -RTMIN+10 -x waybar; }

case $1 in
    toggle)
        if [[ $phase == run ]]; then save idle 0 "$mins"; else save run "$now" "$mins"; fi
        refresh; exit 0 ;;
    length)
        (( mins == 25 )) && mins=50 || mins=25
        save "$phase" "$start" "$mins"
        refresh; exit 0 ;;
esac

if [[ $phase == run ]]; then
    left=$(( mins * 60 - (now - start) ))
    if (( left <= 0 )); then
        save done 0 "$mins"; phase=done
        notify-send -a Timer -u critical "Timer" "$mins minutes are up."
    fi
fi

tip="Left click: start/stop\nRight click: switch 25/50 min\nKeyboard: Super+b then t / l"
case $phase in
    run)  printf '{"text": "TIMER %02d:%02d", "class": "run", "tooltip": "%s min timer\\n%s"}\n' \
              $((left / 60)) $((left % 60)) "$mins" "$tip" ;;
    done) printf '{"text": "TIMER done", "class": "done", "tooltip": "%s minutes are up.\\n%s"}\n' "$mins" "$tip" ;;
    *)    printf '{"text": "TIMER %s", "class": "idle", "tooltip": "%s"}\n' "$mins" "$tip" ;;
esac
