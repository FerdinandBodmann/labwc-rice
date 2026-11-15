#!/bin/sh
# Load input-remapper autoload presets (labwc does not run XDG autostart entries).
# The system-wide input-remapper-autoload.desktop is meant for desktops that do.
input-remapper-control --command stop-all >/dev/null 2>&1
input-remapper-control --command autoload >/dev/null 2>&1
