# Ultimate Labwc Rice

A clean, organized labwc (Openbox-like Wayland compositor) rice configuration.

## Features

- Labwc window manager configuration
- Waybar panel
- Rofi or Fuzzel launcher
- Mako notifications
- Theme system
- Wallpaper management with a GUI thumbnail picker (waypaper)
- Working file dialogs for Flatpak apps (xdg-desktop-portal)
- Utility scripts
- Backup-safe installation

## Dependencies

- labwc
- waybar
- rofi or fuzzel
- mako (notifications)
- swaylock (optional)
- wlogout (optional)
- swaybg (wallpaper backend)
- waypaper (GUI wallpaper picker; optional but recommended)
- xdg-desktop-portal and xdg-desktop-portal-gtk (file dialogs; **required for
  Flatpak apps** to be able to open/save files)
- xdg-desktop-portal-wlr (screenshot/screencast portals)
- jq, brightnessctl, pulseaudio-utils, grim, slurp, wl-clipboard (for scripts)
- fzf and kitty (optional; image-preview picker fallback when waypaper is absent)
- stow (optional, for symlink management)

## Installation

1. Clone this repository to your preferred location:

   ```bash
   git clone <repo-url> ~/.config/labwc-rice
   cd ~/.config/labwc-rice
   ```

2. Run the installer (backs up existing configs):

   ```bash
   ./install.sh
   ```

   Or using make:

   ```bash
   make install
   ```

3. Restart labwc or log out and back in.

## Directory Structure

```
.
├── configs/        # Application configurations
│   ├── labwc/      # Labwc window manager
│   ├── waybar/     # Waybar panel
│   ├── rofi/       # Rofi launcher
│   ├── fuzzel/     # Fuzzel launcher
│   ├── mako/       # Notifications
│   ├── swaylock/   # Swaylock screen locker
│   ├── waypaper/   # GUI wallpaper picker (config template)
│   ├── xdg-desktop-portal/  # Portal routing (file dialogs for Flatpak apps)
│   └── wlogout/    # Wlogout logout menu
├── themes/         # GTK, icon, cursor themes
├── wallpapers/     # Wallpaper collection
├── scripts/        # Utility scripts
├── assets/         # Other assets
├── fonts/          # Local fonts
├── .config/        # Symlink helpers/templates
├── install.sh      # Installation script
├── Makefile        # Make targets
└── README.md       # This file
```

## Usage

### Wallpaper Switching

The GUI picker shows your wallpapers as a clickable thumbnail grid:

```bash
waypaper              # thumbnail grid (also Super+Shift+w)
waypaper --random     # pick a random wallpaper
waypaper --restore    # re-apply the last one
```

`wallpaper-switcher` is a CLI wrapper that delegates to waypaper when it is
installed, and otherwise falls back to a terminal picker (fzf + kitty previews)
or fuzzel:

```bash
~/.local/bin/wallpaper-switcher --list      # list wallpapers
~/.local/bin/wallpaper-switcher --current   # what is set right now
```

### File dialogs in Flatpak apps (portals)

Flatpak apps (browsers, chat clients, ...) are sandboxed and can only open
"open file / save file" dialogs through **xdg-desktop-portal**.

The labwc package ships `/usr/share/xdg-desktop-portal/labwc-portals.conf` with
`default=wlr;*`. The `wlr` backend only implements ScreenCast/Screenshot, and the
`*` fallback resolved to the **GNOME** backend, which cannot start outside a
GNOME session. File dialogs therefore failed silently:

```
Backend call failed: Could not activate remote peer
'org.freedesktop.impl.portal.desktop.gnome': startup job failed
```

The installer links a user-level override (highest precedence, see
`portals.conf(5)`) that prefers the `gtk` backend for FileChooser/Settings while
keeping `wlr` for ScreenCast and Screenshot:

```
configs/xdg-desktop-portal/labwc-portals.conf
  -> ~/.config/xdg-desktop-portal/labwc-portals.conf
```

After editing it, reload the portal:

```bash
systemctl --user restart xdg-desktop-portal
```

### Theme Switching

```bash
~/.local/bin/theme-switcher
```

## Backup

The install script creates timestamped backups of any existing configurations in `~/.config.bak.<timestamp>/`.

## License

See LICENSE file.
