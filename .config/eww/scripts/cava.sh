#!/bin/bash
cava -p ~/.config/cava/eww.conf | while read -r line; do
    echo "$line" | awk -F';' '{
        printf "["
        for(i=1;i<NF;i++){
            printf "%s%s", $i, (i<NF-1?",":"")
        }
        printf "]\n"
    }'
done
