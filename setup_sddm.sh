#!/bin/bash

# Improved SilentSDDM Setup (Hyprlock Match)
DOTFILES_DIR="$HOME/dotfiles-public"
THEME_DIR="/usr/share/sddm/themes/silent"
CONFIG_FILE="$THEME_DIR/configs/hyprlock.conf"
METADATA="$THEME_DIR/metadata.desktop"
WALLPAPER="$HOME/Pictures/Wallpapers/wallpaper.jpg"
DYNAMIC_BG="$THEME_DIR/backgrounds/dynamic_wallpaper.jpg"

echo "1. Syncing wallpaper to theme folder..."
sudo cp "$WALLPAPER" "$DYNAMIC_BG"
sudo chmod 644 "$DYNAMIC_BG"

echo "2. Applying Hyprlock-matched configuration from dotfiles..."
sudo cp "$DOTFILES_DIR/sddm/theme/hyprlock.conf" "$CONFIG_FILE"

echo "3. Updating theme metadata to use hyprlock.conf..."
sudo sed -i 's/^ConfigFile=.*/ConfigFile=configs\/hyprlock.conf/' "$METADATA"

echo "4. Enabling theme and HiDPI in SDDM..."
sudo mkdir -p /etc/sddm.conf.d
sudo cp "$DOTFILES_DIR/sddm/system/theme.conf" /etc/sddm.conf.d/theme.conf
echo -e "[General]\nEnableHiDPI=true" | sudo tee /etc/sddm.conf.d/hidpi.conf > /dev/null

echo "5. Setting up profile picture..."
if [ -f "$DOTFILES_DIR/sddm/theme/avatar.jpg" ]; then
    # Home directory version (kept for consistency)
    cp "$DOTFILES_DIR/sddm/theme/avatar.jpg" "$HOME/.face.icon"
    
    # System-wide version (fixed for SDDM access)
    sudo mkdir -p /usr/share/sddm/faces
    sudo cp "$DOTFILES_DIR/sddm/theme/avatar.jpg" "/usr/share/sddm/faces/$USER.face.icon"
    sudo chmod 644 "/usr/share/sddm/faces/$USER.face.icon"
    echo "Profile picture updated (system-wide and home)."
fi

echo "Done! You can test the theme with: cd $THEME_DIR && ./test.sh"
