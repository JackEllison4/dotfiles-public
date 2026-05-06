#!/usr/bin/env bash

entries="⏻ Shutdown\n⟳ Reboot\n⏾ Suspend\n⍈ Logout"

# Properly quote the variable to prevent word splitting and globbing
selected=$(printf '%b\n' "$entries" | wofi --width 250 --height 210 --dmenu --cache-file /dev/null | awk '{print tolower($2)}')

case $selected in
  shutdown)
    systemctl poweroff
    ;;
  reboot)
    systemctl reboot
    ;;
  suspend)
    systemctl suspend
    ;;
  logout)
    hyprctl dispatch exit
    ;;
esac
