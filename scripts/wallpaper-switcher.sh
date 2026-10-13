#!/usr/bin/env bash
# Wallpaper switcher script

WALL_DIR="${HOME}/Pictures/wallpapers"
if [ ! -d "$WALL_DIR" ] || [ -z "$(ls -A "$WALL_DIR" 2>/dev/null)" ]; then
    WALL_DIR="$(dirname "$(readlink -f "$0")")/../wallpapers"
fi

if [ ! -d "$WALL_DIR" ]; then
    echo "No wallpaper directory found"
    exit 1
fi

# Try to use rofi if available
if command -v rofi >/dev/null 2>&1; then
    wallpaper=$(find "$WALL_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \) | shuf | rofi -dmenu -p "Wallpaper")
elif command -v fuzzel >/dev/null 2>&1; then
    wallpaper=$(find "$WALL_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \) | shuf | fuzzel --dmenu --prompt "Wallpaper")
else
    wallpaper=$(find "$WALL_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \) | shuf -n 1)
fi

[ -z "$wallpaper" ] && exit 0

# Set wallpaper using available tools
if command -v swaybg >/dev/null 2>&1; then
    pkill swaybg 2>/dev/null || true
    swaybg -i "$wallpaper" -m fill &
elif command -v wbg >/dev/null 2>&1; then
    wbg "$wallpaper" &
elif command -v feh >/dev/null 2>&1; then
    feh --bg-fill "$wallpaper" &
elif command -v swww >/dev/null 2>&1; then
    swww img "$wallpaper" &
else
    echo "No wallpaper setter found (swaybg, wbg, feh, swww)"
    exit 1
fi
