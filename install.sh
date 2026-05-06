#!/bin/bash
set -euo pipefail

# Colors for better output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}Starting application installation process...${NC}"

# Check if yay is installed, if not install it
if ! command -v yay &> /dev/null; then
    echo -e "${BLUE}yay not found. Installing yay...${NC}"
    sudo pacman -S --needed git base-devel
    tmpdir=$(mktemp -d) || { echo -e "${RED}Error: mktemp failed${NC}"; exit 1; }
    git clone https://aur.archlinux.org/yay.git "$tmpdir/yay" || { echo -e "${RED}Failed to clone yay${NC}"; rm -rf "$tmpdir"; exit 1; }
    (cd "$tmpdir/yay" && makepkg -si) || { echo -e "${RED}Failed to build yay${NC}"; rm -rf "$tmpdir"; exit 1; }
    rm -rf "$tmpdir"
fi

# Install packages from pkgs.txt
if [ -f pkgs.txt ]; then
    echo -e "${BLUE}Installing packages from pkgs.txt...${NC}"
    yay -S --needed - < pkgs.txt
    echo -e "${GREEN}Installation complete!${NC}"
else
    echo -e "${RED}Error: pkgs.txt not found!${NC}"
    exit 1
fi
