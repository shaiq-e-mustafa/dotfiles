#!/bin/bash
bat=$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -n1)
[ -z "$bat" ] && echo "0" && exit

cap=$(cat "$bat/capacity")
status=$(cat "$bat/status")

icon() {
    if [ "$status" = "Charging" ]; then
        printf '\uf0e7\n'
        return
    fi
    if   [ "$cap" -ge 90 ]; then printf '\uf240\n'
    elif [ "$cap" -ge 60 ]; then printf '\uf241\n'
    elif [ "$cap" -ge 40 ]; then printf '\uf242\n'
    elif [ "$cap" -ge 20 ]; then printf '\uf243\n'
    else printf '\uf244\n'
    fi
}

[ "$1" = "icon" ] && icon && exit
echo "$cap"
