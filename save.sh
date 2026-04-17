#!/bin/bash
cd ~/dotfiles

# Refresh symlinks
echo "Refreshing symlinks..."
stow -v -R -t ~ btop fastfetch hypr kitty lazygit quickshell starship waybar wofi zsh

# Git backup
git add .
git commit -m "Backup: $(date +'%Y-%m-%d %H:%M:%S')"
git push

echo "Dotfiles Backed up and Symlinks Refreshed"
cp /etc/default/grub ~/dotfiles/grub/etc/default/grub

