#!/bin/bash
muted=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -o "MUTED")
vol=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}')

if [ "$muted" = "MUTED" ]; then
    printf '\uf026\n'   # fa-volume-off (mute)
elif [ "$vol" -lt 40 ]; then
    printf '\uf027\n'   # fa-volume-down (low)
else
    printf '\uf028\n'   # fa-volume-up (high)
fi
exit 0
