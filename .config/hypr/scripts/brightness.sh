#!/usr/bin/env bash

STEP=3

get_percent() {
    brightnessctl get | awk -v max="$(brightnessctl max)" '{printf "%.0f", $1/max*100}'
}

ID_FILE="/tmp/osd-notif-id"
osd_notify() {
    local old_id new_id
    old_id=$(cat "$ID_FILE" 2>/dev/null || echo 0)
    new_id=$(notify-send -r "$old_id" -p -t 1500 "$@")
    echo "$new_id" > "$ID_FILE"
}

case "$1" in
    up)
        brightnessctl set "${STEP}%+"
        ;;
    down)
        brightnessctl set "${STEP}%-"
        ;;
esac

osd_notify "Brightness" "$(get_percent)%"
