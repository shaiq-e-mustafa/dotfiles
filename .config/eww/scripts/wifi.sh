#!/bin/bash

icon() {
    state=$(nmcli -t -f WIFI general)
    if [ "$state" = "disabled" ]; then
        printf '\uf05e\n'   # wifi off / disabled
        exit
    fi

    signal=$(nmcli -t -f active,signal dev wifi | grep '^yes' | cut -d: -f2)

    if [ -z "$signal" ]; then
        printf '\uf1eb\n'   # not connected but radio on — generic wifi icon
        exit
    fi

    if   [ "$signal" -ge 80 ]; then printf '\uf1eb\n'   # full signal
    elif [ "$signal" -ge 60 ]; then printf '\uf1eb\n'   # good — placeholder, same glyph until verified
    elif [ "$signal" -ge 40 ]; then printf '\uf1eb\n'   # fair
    elif [ "$signal" -ge 20 ]; then printf '\uf1eb\n'   # weak
    else printf '\uf1eb\n'                               # very weak
    fi
}

status() {
    signal=$(nmcli -t -f active,signal dev wifi | grep '^yes' | cut -d: -f2)
    if [ -z "$signal" ]; then
        echo "Disconnected"
    else
        ssid=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2)
        echo "${ssid} — ${signal}%"
    fi
}

[ "$1" = "icon" ] && icon && exit 0
[ "$1" = "status" ] && status && exit 0
exit 0
