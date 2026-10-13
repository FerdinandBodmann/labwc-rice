#!/usr/bin/env bash
set -euo pipefail

# Ultimate Labwc Rice Installer
# Backs up existing configs and sets up symlinks

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR="${HOME}/.config.bak.${TIMESTAMP}"

echo "=== Ultimate Labwc Rice Installer ==="
echo "Installing from: ${SCRIPT_DIR}"
echo "Backup directory: ${BACKUP_DIR}"
echo ""

# Create directories
mkdir -p "${HOME}/.config"
mkdir -p "${HOME}/.local/bin"

# Backup existing configs if they exist
configs_to_backup=("labwc" "waybar" "rofi" "fuzzel" "swaylock" "wlogout")
for cfg in "${configs_to_backup[@]}"; do
    if [ -e "${HOME}/.config/${cfg}" ] && [ ! -L "${HOME}/.config/${cfg}" ]; then
        mkdir -p "${BACKUP_DIR}"
        mv "${HOME}/.config/${cfg}" "${BACKUP_DIR}/${cfg}" 2>/dev/null || true
        echo "Backed up existing ~/.config/${cfg}"
    fi
done

# Function to create symlink if source exists
link_config() {
    local src="${SCRIPT_DIR}/configs/${1}"
    local dst="${HOME}/.config/${1}"
    if [ -e "${src}" ]; then
        ln -sf "${src}" "${dst}"
        echo "Linked ${dst} -> ${src}"
    else
        echo "Warning: ${src} not found, skipping"
    fi
}

# Link config directories
link_config "labwc"
link_config "waybar"
link_config "rofi"
link_config "fuzzel"
link_config "swaylock"
link_config "wlogout"

# Install scripts to ~/.local/bin
for script in "${SCRIPT_DIR}/scripts"/*.sh; do
    if [ -f "${script}" ]; then
        script_name=$(basename "${script}" .sh)
        ln -sf "${script}" "${HOME}/.local/bin/${script_name}"
        chmod +x "${script}" "${HOME}/.local/bin/${script_name}"
        echo "Installed script: ${script_name}"
    fi
done

# Copy themes if they exist
if [ -d "${SCRIPT_DIR}/themes" ] && [ "$(ls -A "${SCRIPT_DIR}/themes")" ]; then
    mkdir -p "${HOME}/.local/share/themes"
    cp -r "${SCRIPT_DIR}/themes"/* "${HOME}/.local/share/themes/" 2>/dev/null || true
    echo "Installed themes to ~/.local/share/themes"
fi

# Copy wallpapers if they exist
if [ -d "${SCRIPT_DIR}/wallpapers" ] && [ "$(ls -A "${SCRIPT_DIR}/wallpapers")" ]; then
    mkdir -p "${HOME}/Pictures/wallpapers"
    cp -r "${SCRIPT_DIR}/wallpapers"/* "${HOME}/Pictures/wallpapers/" 2>/dev/null || true
    echo "Installed wallpapers to ~/Pictures/wallpapers"
fi

# Copy fonts if they exist
if [ -d "${SCRIPT_DIR}/fonts" ] && [ "$(ls -A "${SCRIPT_DIR}/fonts")" ]; then
    mkdir -p "${HOME}/.local/share/fonts"
    cp -r "${SCRIPT_DIR}/fonts"/* "${HOME}/.local/share/fonts/" 2>/dev/null || true
    fc-cache -f -v >/dev/null 2>&1 || true
    echo "Installed fonts to ~/.local/share/fonts"
fi

echo ""
echo "Installation complete!"
echo "Backups saved to: ${BACKUP_DIR}"
