#!/bin/bash

PIPE="$HOME/.cache/quickshell/ipc"
mkdir -p "$(dirname "$PIPE")"
[ -p "$PIPE" ] || mkfifo "$PIPE"

# Ensure clean exit
trap "rm -f $PIPE" EXIT

# Listen for commands in a tight loop but blocked by the FIFO read
while true; do
    if read -r line < "$PIPE"; then
        echo "$line"
    fi
done
