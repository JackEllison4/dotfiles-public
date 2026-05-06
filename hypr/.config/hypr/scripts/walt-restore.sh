#!/bin/bash

# Path to walt rotation state
STATE_FILE="$HOME/.config/walt/rotation-state.json"
LOG_FILE="$HOME/.config/walt/restore.log"

echo "$(date): Starting walt-restore.sh" >> "$LOG_FILE"

# Wait for hyprpaper to be ready
# We check if the process is running
MAX_WAIT=50
WAIT_COUNT=0
# Wait for hyprpaper to be ready and responding to IPC
MAX_WAIT=50
WAIT_COUNT=0
while ! hyprctl hyprpaper listactive > /dev/null 2>&1; do
    sleep 0.2
    WAIT_COUNT=$((WAIT_COUNT+1))
    if [ $WAIT_COUNT -ge $MAX_WAIT ]; then
        echo "$(date): hyprpaper not responding after 10s. Exiting." >> "$LOG_FILE"
        exit 1
    fi
done
echo "$(date): hyprpaper found. Proceeding with restore." >> "$LOG_FILE"

# Get last wallpaper from walt's state
if [ -f "$STATE_FILE" ]; then
    LAST_WALL=$(jq -r '.last_wallpaper' "$STATE_FILE")
    
    if [ -f "$LAST_WALL" ]; then
        # Tell hyprpaper to load and set the wallpaper
        # Ignore error from preload if it's already loaded
        hyprctl hyprpaper preload "$LAST_WALL" > /dev/null 2>&1
        
        if hyprctl hyprpaper wallpaper ",$LAST_WALL"; then
            echo "$(date): Walt: Restored wallpaper $LAST_WALL" >> "$LOG_FILE"
        else
            echo "$(date): Walt: Failed to apply wallpaper via hyprctl" >> "$LOG_FILE"
        fi
    else
        echo "$(date): Walt: Last wallpaper file not found: $LAST_WALL" >> "$LOG_FILE"
    fi
else
    echo "$(date): Walt: State file not found: $STATE_FILE" >> "$LOG_FILE"
fi
