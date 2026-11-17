#!/usr/bin/env bash
# Hint label shown next to a bar item while the Super+b "bar mode" is active.
# Outside the mode it prints a zero-width space, so the module keeps its slot
# (and spacing) but is invisible. bar-listener.sh toggles the flag file.
if [[ -e ${XDG_RUNTIME_DIR:-/tmp}/waybar-barmode ]]; then
    printf '{"text": "%s", "class": "on"}\n' "$1"
else
    printf '{"text": "\\u200b", "class": "off"}\n'
fi
