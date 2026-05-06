#!/bin/bash
set -euo pipefail
cd ~/dotfiles-public || { echo "Error: Cannot change to ~/dotfiles directory" >&2; exit 1; }

# Update grub config first (before commit)
echo "Updating grub config..."
cp /etc/default/grub ~/dotfiles-public/grub/etc/default/grub

# Refresh symlinks
echo "Refreshing symlinks..."
stow -v -R -t ~ btop fastfetch hypr kitty lazygit quickshell starship waybar wofi zsh

# Backup SDDM configs
echo "Backing up SDDM configs..."
cp /usr/share/sddm/themes/silent/configs/hyprlock.conf ~/dotfiles-public/sddm/theme/hyprlock.conf 2>/dev/null || echo "Warning: SDDM theme config not found"
cp /etc/sddm.conf.d/theme.conf ~/dotfiles-public/sddm/system/theme.conf 2>/dev/null || echo "Warning: SDDM system config not found"

# Backup Avatar
echo "Backing up Avatar..."
cp ~/.face.icon ~/dotfiles-public/sddm/theme/avatar.jpg 2>/dev/null || echo "Warning: Avatar not found"

# Update package list
echo "Updating package list..."
yay -Qeq > pkgs.txt

# Git backup
git add .
git commit -m "Backup: $(date +'%Y-%m-%d %H:%M:%S')"
git push

echo "Dotfiles Backed up and Symlinks Refreshed"
