#!/usr/bin/env bash

# Google Calendar Event Parser (wrapper)
# Delegates to Python script for parsing

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_SCRIPT="${SCRIPT_DIR}/get_calendar.py"

if [ ! -f "$PYTHON_SCRIPT" ]; then
    echo "Error: Python script not found at $PYTHON_SCRIPT" >&2
    exit 1
fi

# Run Python script
python3 "$PYTHON_SCRIPT" "$@"
