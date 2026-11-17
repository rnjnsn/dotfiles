#!/usr/bin/env bash
# Network actions for the waybar network menu and the Super+b keyboard mode.
#   net.sh hotspot     connect to the phone's hotspot (retries while it appears)
#   net.sh pick        fuzzel list of nearby Wi-Fi; asks for a password if new
#   net.sh wifi        Wi-Fi radio on/off
#   net.sh disconnect  disconnect the current Wi-Fi
#   net.sh tui         open nmtui in a terminal
PHONE="Renes iPhone"     # NetworkManager connection name of the phone hotspot
DEV=$(nmcli -t -f DEVICE,TYPE dev | awk -F: '$2=="wifi"{print $1; exit}')

note() { notify-send -a Network -h string:x-dunst-stack-tag:net "$@"; }

case $1 in
hotspot)
    nmcli radio wifi on
    note "Hotspot" "Looking for $PHONE… (open Personal Hotspot on the phone)"
    # iPhones only advertise the hotspot while its settings screen is open
    # (or shortly after), so keep scanning for ~40 s.
    for _ in $(seq 8); do
        nmcli dev wifi rescan ifname "$DEV" 2>/dev/null
        sleep 3
        if nmcli -t -f SSID dev wifi list ifname "$DEV" --rescan no | grep -Fxq "$PHONE"; then
            if out=$(nmcli --wait 30 con up id "$PHONE" 2>&1); then
                note "Hotspot" "Connected to $PHONE"; exit 0
            fi
        fi
        sleep 2
    done
    note -u critical "Hotspot" "Couldn't find $PHONE. Is Personal Hotspot on?${out:+\n$out}"
    exit 1 ;;
pick)
    note "Wi-Fi" "Scanning…"
    saved=$(nmcli -t -f NAME,TYPE con show | awk -F: '$2=="802-11-wireless"{print $1}')
    # IN-USE:SIGNAL:SECURITY:SSID  (SSID last, so colons in it survive)
    list=$(nmcli -t -e no -f IN-USE,SIGNAL,SECURITY,SSID dev wifi list ifname "$DEV" --rescan yes |
        awk -F: '{ ssid=$4; for(i=5;i<=NF;i++) ssid=ssid":"$i
                   if (ssid=="" || seen[ssid]++) next
                   printf "%s %3s%%  %-4s %s\n", ($1=="*"?"●":" "), $2, ($3==""?"open":"lock"), ssid }')
    [[ -z $list ]] && { note "Wi-Fi" "No networks found"; exit 1; }
    choice=$(printf '%s\n' "$list" | fuzzel --dmenu -p "Wi-Fi: " --width 50) || exit 0
    ssid=${choice:13}
    sec=${choice:8:4}
    [[ -z $ssid ]] && exit 0
    if grep -Fxq "$ssid" <<<"$saved"; then
        out=$(nmcli --wait 30 con up id "$ssid" 2>&1)
    elif [[ $sec == lock ]]; then
        pw=$(fuzzel --dmenu --password -p "Password for $ssid: " --lines 0 </dev/null) || exit 0
        out=$(nmcli --wait 30 dev wifi connect "$ssid" password "$pw" ifname "$DEV" 2>&1)
    else
        out=$(nmcli --wait 30 dev wifi connect "$ssid" ifname "$DEV" 2>&1)
    fi
    if [[ $? -eq 0 ]]; then note "Wi-Fi" "Connected to $ssid"; else note -u critical "Wi-Fi" "$out"; fi ;;
wifi)
    if [[ $(nmcli radio wifi) == enabled ]]; then nmcli radio wifi off; note "Wi-Fi" "Off"
    else nmcli radio wifi on; note "Wi-Fi" "On"; fi ;;
disconnect)
    nmcli dev disconnect "$DEV" && note "Wi-Fi" "Disconnected" ;;
tui)
    foot -e nmtui ;;
*)
    echo "usage: net.sh hotspot|pick|wifi|disconnect|tui" >&2; exit 2 ;;
esac
