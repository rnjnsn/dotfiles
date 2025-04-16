# ~/.bash_profile

# Load standard bash config
[[ -f ~/.bashrc ]] && . ~/.bashrc

# Start Hyprland only on first TTY and only if no DISPLAY is set
if [[ -z $DISPLAY ]] && [[ $(tty) == /dev/tty1 ]]; then
    echo "[.bash_profile] Starting Hyprland from tty1..."
    sleep 2
    exec Hyprland > ~/.hyprland.log 2>&1
fi
