#!/usr/bin/env bash

# This script monitors Hyprland events and prints "1" if the active window is fullscreen, "0" otherwise.
# Robustly handles cases with no active windows.

check_fullscreen() {
    # Get active window data in JSON format
    active_json=$(hyprctl activewindow -j 2>/dev/null)
    
    # If no window is active or JSON is empty/invalid
    if [[ -z "$active_json" || "$active_json" == "{}" || "$active_json" == "null" ]]; then
        echo "0"
        return
    fi
    
    # Check fullscreen status (0 = no, 1 = fullscreen, 2 = maximized/full)
    if echo "$active_json" | jq -e '.fullscreen != 0' >/dev/null 2>&1; then
        echo "1"
    else
        echo "0"
    fi
}

# Initial check
check_fullscreen

# Listen to Hyprland socket for events
socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do
    case $line in
        fullscreen\>\>*|activewindow\>\>*|workspace\>\>*)
            check_fullscreen
            ;;
    esac
done
