# Labwc Configuration

This directory contains the core labwc (Wayland window manager) configuration files.

## Files

- **rc.xml** - Main configuration: keybindings, window rules, decorations, margins, workspaces, touchpad settings, output configuration
- **menu.xml** - Root menu structure for right-click/left-click on desktop
- **autostart** - Scripts and applications to launch on startup (executable)
- **environment** - Environment variables for labwc session
- **rc.xml.example** - Example configuration (reference)

## Laptop-Friendly Features

- **Touchpad**: Natural scrolling, tap-to-click, tap-and-drag, drag-lock enabled
- **Brightness**: XF86 brightness keys bound to `brightnessctl` if available
- **Audio**: Volume and media keys bound to PulseAudio/playerctl
- **Power management**: swayidle integration for auto-lock/suspend
- **Outputs**: Configurable display layout (auto-detected by default)

## Keybindings (Super/Win key)

| Key | Action |
|---|---|
| `Super + Space` | Fuzzel launcher |
| `Super + d` | Rofi launcher |
| `Super + Return` | Kitty terminal |
| `Super + e` | Thunar file manager |
| `Super + q` | Close window |
| `Super + f` | Maximize/toggle fullscreen |
| `Super + h/j/k/l` | Focus windows |
| `Super + 1-4` | Switch workspaces |
| `Print` / `Shift+Print` | Screenshots |
| `Super + Shift + l` | Lock screen |
| `XF86*` | Brightness, volume, media controls |

## Notes

- Make sure required utilities are installed (see main README dependencies)
- Edit `rc.xml` to customize keybindings, themes, margins, etc.
- Add custom autostart scripts to `autostart.d/` directory if needed
