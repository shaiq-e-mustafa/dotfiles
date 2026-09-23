#!/bin/bash
vol=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}')

if [ -z "$vol" ]; then
    echo "50"
else
    echo "$vol"
fi
exit 0
