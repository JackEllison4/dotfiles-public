#!/usr/bin/env bash

# Check for available package updates
# Returns the total count of available updates (official repos + AUR)

count=0

# Check official repos
if command -v checkupdates &>/dev/null; then
    repo_count=$(checkupdates 2>/dev/null | wc -l)
    count=$((count + repo_count))
fi

# Check AUR packages
if command -v yay &>/dev/null; then
    aur_count=$(yay -Qua 2>/dev/null | wc -l)
    count=$((count + aur_count))
elif command -v paru &>/dev/null; then
    aur_count=$(paru -Qua 2>/dev/null | wc -l)
    count=$((count + aur_count))
fi

echo "$count"
