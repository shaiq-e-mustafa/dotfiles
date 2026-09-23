#!/bin/bash
level=$(brightnessctl -d intel_backlight -m | awk -F, '{print $4}' | tr -d '%')

if [ "$level" -lt 40 ]; then
    printf '\uf186\n'   # low brightness — verify this codepoint yourself
else
    printf '\uf185\n'   # high brightness (sun) — already confirmed working
fi
exit 0
