#!/bin/bash

# Kill any existing swaybg instances
pkill swaybg

# Wait a moment for process to terminate
sleep 0.5

# Launch swaybg with wallpaper
swaybg -i /home/rene/wallpapers/fuji.jpg -m fill &
