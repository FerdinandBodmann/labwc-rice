#!/usr/bin/env bash
#
# Ultimate Labwc Rice - wallpaper picker / setter
#
# Usage:
#   wallpaper-switcher              pick one (image previews in kitty, else fuzzel)
#   wallpaper-switcher --random     pick a random wallpaper
#   wallpaper-switcher --restore    re-apply the last wallpaper (random, then colour)
#   wallpaper-switcher --current    print the current wallpaper
#   wallpaper-switcher --list       list all wallpapers that would be offered
#   wallpaper-switcher FILE         apply FILE directly
#   wallpaper-switcher --dir DIR    also search DIR (repeatable)
#
# Extra directories can be listed in ~/.config/labwc/wallpaper-dirs.
# Last selection is stored in $XDG_STATE_HOME/labwc/wallpaper (~/.local/state).
# Set LW_WALLPAPER_MODE to override the swaybg scaling mode (fill/fit/stretch/
# center/tile), default: fill.

set -u

STATE="${XDG_STATE_HOME:-$HOME/.local/state}/labwc/wallpaper"
MODE="${LW_WALLPAPER_MODE:-fill}"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

action="pick"
target=""
extra_dirs=()
orig_args=()
for a in "$@"; do orig_args+=("$a"); done

while [ $# -gt 0 ]; do
    case "$1" in
        --random)  action="random" ;;
        --restore) action="restore" ;;
        --current) action="current" ;;
        --list)    action="list" ;;
        --dir)     shift; [ $# -gt 0 ] && extra_dirs+=("$1") ;;
        -h|--help) sed -n '3,18p' "${BASH_SOURCE[0]}" | sed 's/^#\s\{0,1\}//'; exit 0 ;;
        -*)        echo "wallpaper-switcher: unknown option: $1" >&2; exit 2 ;;
        *)         target="$1" ;;
    esac
    shift
done

# --- Where to look -----------------------------------------------------------
dirs=()
add_dir() { [ -n "${1:-}" ] && [ -d "$1" ] && dirs+=("$1"); }

add_dir "${HOME}/Pictures/Wallpapers"        # this machine's collection
add_dir "${HOME}/Pictures/wallpapers"
add_dir "${HOME}/Pictures"
add_dir "${SCRIPT_DIR}/../wallpapers"        # the rice's own wallpapers/
add_dir "/usr/share/backgrounds"
if [ -f "${XDG_CONFIG_HOME:-$HOME/.config}/labwc/wallpaper-dirs" ]; then
    while IFS= read -r line; do
        case "$line" in ''|'#'*) continue ;; esac
        add_dir "${line/#\~/$HOME}"
    done < "${XDG_CONFIG_HOME:-$HOME/.config}/labwc/wallpaper-dirs"
fi
for d in ${extra_dirs[@]+"${extra_dirs[@]}"}; do add_dir "$d"; done

list_wallpapers() {
    [ ${#dirs[@]} -eq 0 ] && return 0
    find "${dirs[@]}" -maxdepth 1 -type f \
        \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \
           -o -iname '*.webp' -o -iname '*.bmp' \) 2>/dev/null | sort -u
}

# --- Applying ----------------------------------------------------------------
apply() {
    local img="$1"
    if [ ! -f "$img" ]; then
        echo "wallpaper-switcher: not a file: $img" >&2
        return 1
    fi
    if command -v swaybg >/dev/null 2>&1; then
        pkill -x swaybg 2>/dev/null || true
        nohup swaybg -i "$img" -m "$MODE" >/dev/null 2>&1 &
    elif command -v wbg >/dev/null 2>&1; then
        pkill -x wbg 2>/dev/null || true
        nohup wbg "$img" >/dev/null 2>&1 &
    else
        echo "wallpaper-switcher: no setter found (install swaybg)" >&2
        return 1
    fi
    mkdir -p "$(dirname "$STATE")"
    printf '%s\n' "$img" > "$STATE"
}

apply_colour() {
    command -v swaybg >/dev/null 2>&1 || return 0
    pkill -x swaybg 2>/dev/null || true
    nohup swaybg -c "${1:-#1e1e2e}" >/dev/null 2>&1 &
}

# --- Picking -----------------------------------------------------------------
pick_with_fzf() {
    local list="$1" preview_args=()
    if [ -n "${KITTY_WINDOW_ID:-}" ] && command -v kitty >/dev/null 2>&1; then
        # Real image previews via the kitty graphics protocol
        preview_args=(--preview 'kitty +kitten icat --clear --stdin=no --transfer-mode=memory --place=${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}@0x0 --scale-up -- {2}')
        preview_args+=(--preview-window 'right:60%:border-left')
    fi
    # Feed "basename<TAB>full path": display the basename, keep the path in field 2
    while IFS= read -r f; do
        printf '%s\t%s\n' "${f##*/}" "$f"
    done <<< "$list" \
    | fzf --delimiter='\t' --with-nth=1 --height=100% --layout=reverse --border \
          --info=inline --prompt='Wallpaper > ' \
          --header='Enter: set wallpaper   Esc: cancel' \
          ${preview_args[@]+"${preview_args[@]}"}
}

pick_with_fuzzel() {
    local list="$1" choice
    choice="$(printf '%s\n' "$list" | sed 's|.*/||' \
        | fuzzel --dmenu --prompt='Wallpaper > ' 2>/dev/null)" || true
    [ -z "$choice" ] && return 0
    # Resolve the basename back to a full path (first match wins)
    while IFS= read -r f; do
        [ "${f##*/}" = "$choice" ] && { printf '%s\n' "$f"; return 0; }
    done <<< "$list"
}

pick() {
    local list; list="$(list_wallpapers)"
    if [ -z "$list" ]; then
        echo "wallpaper-switcher: no wallpapers found." >&2
        echo "Put images in ${HOME}/Pictures/Wallpapers, or add directories to" >&2
        echo "${XDG_CONFIG_HOME:-$HOME/.config}/labwc/wallpaper-dirs" >&2
        return 1
    fi

    # Not in a terminal that can draw images? Re-open ourselves in kitty so the
    # previews work when launched from a keybind or the desktop menu.
    if [ -z "${KITTY_WINDOW_ID:-}" ] && command -v kitty >/dev/null 2>&1; then
        exec kitty --class lw-wallpaper -T "Wallpaper" \
            -o initial_window_width=120c -o initial_window_height=36c \
            -e "$0" ${orig_args[@]+"${orig_args[@]}"}
    fi

    local selected=""
    if command -v fzf >/dev/null 2>&1; then
        selected="$(pick_with_fzf "$list")" || true
        selected="${selected#*$'\t'}"     # output is the original "name<TAB>path" line
    elif command -v fuzzel >/dev/null 2>&1; then
        selected="$(pick_with_fuzzel "$list")" || true
    else
        echo "wallpaper-switcher: need fzf or fuzzel for the picker" >&2
        return 1
    fi

    [ -z "$selected" ] && return 0
    apply "$selected"
}

# --- Main --------------------------------------------------------------------
# If waypaper is installed it owns the wallpaper state (the GUI picker with
# thumbnails, Super+Shift+w). Delegate to it so `wallpaper-switcher --current`
# and the autostart restore agree with what the GUI last set.
if command -v waypaper >/dev/null 2>&1 && [ "$action" != "list" ]; then
    waypaper_current() {
        waypaper --list 2>/dev/null \
            | python3 -c 'import json,sys
try:
    data = json.load(sys.stdin)
except Exception:
    sys.exit(0)
for entry in data:
    if entry.get("wallpaper"):
        print(entry["wallpaper"])
        break' 2>/dev/null
    }

    case "$action" in
        current)
            waypaper_current ;;
        random)
            waypaper --random >/dev/null 2>&1 || apply_colour ;;
        restore)
            if [ -n "$(waypaper_current)" ]; then
                waypaper --restore >/dev/null 2>&1 || apply_colour
            else
                waypaper --random >/dev/null 2>&1 || apply_colour
            fi ;;
        pick)
            if [ -n "$target" ]; then
                waypaper --wallpaper "$target" >/dev/null 2>&1 || apply "$target"
            else
                exec waypaper
            fi ;;
    esac
    exit 0
fi

case "$action" in
    current) current="$(cat "$STATE" 2>/dev/null || true)"; [ -n "$current" ] && printf '%s\n' "$current" ;;
    list)    list_wallpapers ;;
    random)
        w="$(list_wallpapers | shuf -n 1)"
        if [ -n "$w" ]; then apply "$w"; else apply_colour; fi ;;
    restore)
        w="$(cat "$STATE" 2>/dev/null || true)"
        if [ -z "$w" ] || [ ! -f "$w" ]; then w="$(list_wallpapers | shuf -n 1)"; fi
        if [ -n "$w" ]; then apply "$w"; else apply_colour; fi ;;
    pick)
        if [ -n "$target" ]; then apply "$target"; else pick; fi ;;
esac
