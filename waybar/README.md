# Waybar Configuration

A lightweight and reliable bar with widgets for time, media controls, volume controls, battery status, power profiles, workspace status, and more.

![Preview](image.png)

## Features

- **MPRIS Integration**: Integrated media player controls with `playerctl` support.
- **Power Management**: Direct integration with `power-profiles-daemon`.
- **Time Tracking**: Integrated `arbtt` stats to monitor active time spent.
- **System Monitors**: Real-time tracking of memory, battery, and network status.
- **Clean Aesthetic**: Minimalist design that stays out of the way.

## Required Packages

To ensure all modules function correctly, please install the following:

### Core
- `waybar`: The status bar itself.
- `hyprland`: Required for workspace monitoring.

### Modules & Dependencies
- `playerctl`: Required for media (mpris) controls.
- `arbtt`: Required for the "time spent" module.
- `pavucontrol` & `volumectl`: For audio management.
- `network-manager-applet` (provides `nm-connection-editor`): For network management.
- `blueman`: For Bluetooth management.
- `power-profiles-daemon`: For power profile switching.
- `libnotify` (for `notify-send`): Used in some scripts.

## Usage

If you are using GNU Stow:
```bash
stow waybar
```

The bar will typically start automatically if called in your Hyprland configuration:
```bash
exec-once = waybar
```

## ⚙️ Configuration

The configuration is located in `~/.config/waybar/config.jsonc` and styling in `~/.config/waybar/style.css`.

![Preview](image.png)