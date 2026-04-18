# Quickshell Configuration

A more modified and customized shell with quicksettings, audio/network controls, weather, calendar, notifications, media controls, screen controls, screenshot widget, and more.

![Preview](image1.png)
![Preview](image2.png)
![Preview](image3.png)
![Preview](image4.png)
![Preview](image5.png)
![Preview](image6.png)

## Features

- **Control Center**: Quick access to audio, network, battery, and system power settings.
- **Integrated Notifications**: A custom notification widget that matches the system theme.
- **Focus Time**: A built-in productivity tracker with a dedicated daemon.
- **Dynamic Bar**: Supports auto-hide, floating modes, and top/bottom positioning.
- **Calendar & Weather**: Integrated widgets for scheduling and local weather updates.
- **Screenshot Utility**: A custom UI for taking regional, window, or full-screen screenshots.

## Required Packages

To ensure all features work correctly, please install the following:

### Core
- `quickshell`: The shell framework itself.
- `qt6-svg`, `qt6-graphicaleffects`: Essential for icons and UI effects.
- `socat`: Used for IPC between scripts and the shell.
- `jq`: Required for parsing JSON data in scripts.

### Utilities
- `grim`, `slurp`: Required for the screenshot widget.
- `libnotify`: Required for system-wide notification support.
- `wl-clipboard`: Required for clipboard integration.
- `python3`: Required for the Focus Time daemon.

### Recommended (for full functionality)
- `matugen`: For dynamic color generation (if enabled).
- `power-profiles-daemon`: For power management control.

## Usage

If you are using GNU Stow:
```bash
stow quickshell
```

To start the shell:
```bash
quickshell --path ~/.config/quickshell/shell.qml
```

## Configuration

Settings like bar position and auto-hide can be adjusted in `~/.config/quickshell/settings.json`.
