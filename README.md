# Ultimate Labwc Rice

A clean, organized labwc (Openbox-like Wayland compositor) rice configuration.

## Features

- Labwc window manager configuration
- Waybar panel
- Rofi or Fuzzel launcher
- Theme system
- Wallpaper management
- Utility scripts
- Backup-safe installation

## Dependencies

- labwc
- waybar
- rofi or fuzzel
- swaylock (optional)
- wlogout (optional)
- feh, swaybg, or wpaperd (for wallpapers)
- jq, brightnessctl, pulseaudio-utils, grim, slurp, wl-clipboard (for scripts)
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
│   ├── swaylock/   # Swaylock screen locker
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

```bash
~/.local/bin/wallpaper-switcher
```

### Theme Switching

```bash
~/.local/bin/theme-switcher
```

## Backup

The install script creates timestamped backups of any existing configurations in `~/.config.bak.<timestamp>/`.

## License

See LICENSE file.
