#!/bin/bash
# Toggle between transparent and translucent bar background

SETTINGS_FILE="$HOME/.config/quickshell/settings.json"
if [ ! -f "$SETTINGS_FILE" ]; then
    exit 1
fi

CURRENT_STYLE=$(jq -r '.bar.backgroundStyle' "$SETTINGS_FILE")

if [ "$CURRENT_STYLE" == "transparent" ]; then
    NEW_STYLE="translucent"
else
    NEW_STYLE="transparent"
fi

# Use a temporary file to safely update the settings
jq ".bar.backgroundStyle = \"$NEW_STYLE\"" "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp" && mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"

# Signal the bar to reload settings instantly
echo "reload" > ~/.cache/quickshell/bar-signal

echo "Bar background style toggled to: $NEW_STYLE"
