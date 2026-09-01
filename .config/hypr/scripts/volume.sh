#!/usr/bin/env bash

SINK="@DEFAULT_AUDIO_SINK@"
STEP=5

get_volume() {
    wpctl get-volume "$SINK" | sed -E 's/.* ([0-9.]+).*/\1/'
}

get_percent() {
    awk -v v="$(get_volume)" 'BEGIN{printf "%.0f", v*100}'
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
        wpctl set-volume "$SINK" "${STEP}%+"
        ;;
    down)
        wpctl set-volume "$SINK" "${STEP}%-"
        ;;
    toggle|mute)
        wpctl set-mute "$SINK" toggle
        ;;
esac

if wpctl get-volume "$SINK" | grep -q MUTED; then
    osd_notify "Volume" "Muted"
else
    osd_notify "Volume" "$(get_percent)%"
fi
