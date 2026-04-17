#!/usr/bin/env bash

# Paths
save_dir="$HOME/Pictures/Screenshots"
mkdir -p "$save_dir"

# Args: mode (output, window, region), delay, save_to_disk, copy_to_clipboard, location
mode=${1:-"output"}
delay=${2:-0}
save_to_disk=${3:-"true"}
copy_to_clipboard=${4:-"true"}
custom_location=${5:-"$save_dir"}

if [ "$custom_location" != "$save_dir" ]; then
    save_dir=$(eval echo "$custom_location")
    mkdir -p "$save_dir"
fi

timestamp=$(date +%Y-%m-%d_%H-%M-%S)
filename="screenshot_${timestamp}.png"
filepath="${save_dir}/${filename}"

# Apply delay
if [ "$delay" -gt 0 ]; then
    sleep "$delay"
fi

# Capture function
capture() {
    case $mode in
        "output")
            grim "$filepath"
            ;;
        "window")
            # For window selection, we use slurp with hyprctl
            grim -g "$(hyprctl clients -j | jq -r ".[] | select(.workspace.id | . != -1) | \"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])\"" | slurp)" "$filepath"
            ;;
        "region")
            grim -g "$(slurp)" "$filepath"
            ;;
        *)
            grim "$filepath"
            ;;
    esac
}

# Run capture
if capture; then
    # Post-process
    if [ "$copy_to_clipboard" = "true" ]; then
        wl-copy < "$filepath"
    fi
    
    if [ "$save_to_disk" = "false" ]; then
        rm "$filepath"
        msg="Screenshot copied to clipboard"
    else
        msg="Screenshot saved to ${filename}"
    fi
    
    notify-send -i "camera-photo" "Screenshot" "$msg"
else
    notify-send -u critical "Screenshot" "Failed to take screenshot"
fi
