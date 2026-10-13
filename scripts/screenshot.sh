#!/usr/bin/env bash
# Screenshot utility using grim/slurp/waybar

if command -v grim >/dev/null 2>&1; then
    if command -v slurp >/dev/null 2>&1; then
        grim -g "$(slurp)" ~/Pictures/screenshot_$(date +%Y%m%d_%H%M%S).png
    else
        grim ~/Pictures/screenshot_$(date +%Y%m%d_%H%M%S).png
    fi
else
    echo "grim not found"
    exit 1
fi
