get_workspaces() {
    active=$(hyprctl activeworkspace -j | jq '.id')
    list=$(hyprctl workspaces -j | jq -c --argjson active "$active" \
      'map({id: .id, active: (.id == $active)}) | sort_by(.id)')
    idx=$(echo "$list" | jq '[.[] | .active] | index(true) // 0')
    jq -cn --argjson list "$list" --argjson idx "$idx" '{list: $list, activeIndex: $idx}'
}

get_workspaces

socat -u UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" - | while read -r line; do
    case "$line" in
        workspace*|createworkspace*|destroyworkspace*|focusedmon*)
            get_workspaces
            ;;
    esac
done
exit 0
