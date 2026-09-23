#!/bin/bash
level=$(brightnessctl -d intel_backlight -m | awk -F, '{print $4}' | tr -d '%')

if [ -z "$level" ]; then
    echo "50"
else
    echo "$level"
fi
exit 0
