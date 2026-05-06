# Complete System Help & Shortcuts

## Terminal User Interfaces (TUIs)
| Command | Description |
| :--- | :--- |
| `yazi` | **File Manager**: Blazing fast, preview-heavy file management. (`SUPER + E`) |
| `btop` | **System Monitor**: CPU, Memory, Disk, and Network monitoring. |
| `htop` | **System Monitor**: CPU, Memory, Disk, and Network monitoring. |
| `jolt` | **Energy Monitor**: Beautiful battery and power consumption tracker. |
| `batctl` | **Battery Monitor**: Monitor battery health and usage. |
| `netorbit`| **Network Map**: Live terminal map of your outgoing network traffic. |
| `lazygit`| **Git UI**: Simple and powerful interface for git operations. |
| `impala` | **Wi-Fi**: Manage wireless connections and saved networks. |
| `bluetui` | **Bluetooth**: Manage devices, pairing, and connections. |
| `nordvpn-tui`| **VPN**: Connect and manage your NordVPN status. |
| `nmtui`  | **Network**: Standard NetworkManager TUI (Wi-Fi/Ethernet). |
| `fastfetch`| **System Info**: Quick overview of your hardware and OS. |
| `sniffcli`| **Network Scanner**: Traceroute for network devices. |
| `terminal-rain` | **Terminal Rain**: A rainy terminal animation |
| `cbonsai` | **CBonsai**: A bonsai tree in your terminal |
| `alsamixer` | **Alsamixer**: A TUI for controlling audio |
| `lazygit` | **Git UI**: Simple and powerful interface for git operations |


## Keyboard Shortcuts (SUPER = Windows Key)

### Window Management
- `SUPER + Q`: Open Terminal (Kitty)
- `SUPER + C`: Close Active Window
- `SUPER + V`: Toggle Floating Mode
- `SUPER + F`: Fullscreen Toggle
- `SUPER + P`: Pseudo Tiling (Dwindle)
- `SUPER + J`: Toggle Split Direction
- `SUPER + Arrow Keys`: Move Focus Between Windows
- `SUPER + ALT + Arrow Keys`: Resize Active Window


### Mouse Control
- `SUPER + Left Click + Drag`: **Move Window**
- `SUPER + Right Click + Drag`: **Resize Window**
- `SUPER + Scroll Wheel`: Switch Workspaces

### Launchers & Apps
- `SUPER + E`: File Manager (Yazi)
- `SUPER + R`: App Launcher (Wofi)
- `SUPER + U`: Quick Shell Launcher
- `SUPER + B`: Google Chrome
- `SUPER + SHIFT + B`: Microsoft Edge
- `SUPER + W`: Wallpaper Picker (Walt)
- `SUPER + Escape`: Lock Screen (Hyprlock)
- `SUPER + M`: Power Menu / Exit
- `SUPER + SHIFT + T`: Toggle Top Bar Background

### Workspaces
- `SUPER + [1-0]`: Switch to Workspace 1-10
- `SUPER + SHIFT + [1-0]`: Move Active Window to Workspace 1-10
- `SUPER + S`: Toggle Special Workspace (Scratchpad)

### Screenshots & Media
- `SUPER + SHIFT + S`: Select area and take screenshot
- `Print`: Capture entire screen
- `Vol Up/Down`: Adjust Volume
- `Brightness Up/Down`: Adjust Brightness
- `Media Next/Prev/Play`: Media Controls

## Stowing

stow -v -R -t ~ btop fastfetch hypr kitty lazygit quickshell starship swaync waybar wofi zsh

or 

stow -v -R -t ~ $(ls -d */ | grep -vE ".git|sddm|grub|scratch")

---
*Tip: Type `help` anytime to see this guide!*
