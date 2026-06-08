#!/usr/bin/env bash

AC_ONLINE="/sys/class/power_supply/macsmc-ac/online"

apply_battery_saver() {
    hyprctl keyword decoration:blur:enabled false
    hyprctl keyword decoration:active_opacity 1.0
    hyprctl keyword decoration:inactive_opacity 0.9
    hyprctl keyword decoration:drop_shadow false
    hyprctl keyword animations:enabled false
    notify-send -t 2000 "Battery Saver" "Power saving mode enabled"
}

apply_performance() {
    hyprctl keyword decoration:blur:enabled true
    hyprctl keyword decoration:active_opacity 0.85
    hyprctl keyword decoration:inactive_opacity 0.7
    hyprctl keyword decoration:drop_shadow true
    hyprctl keyword animations:enabled false
    notify-send -t 2000 "Performance" "Performance mode restored"
}

update_mode() {
    if [[ $(cat "$AC_ONLINE") -eq 1 ]]; then
        apply_performance
    else
        apply_battery_saver
    fi
}

update_mode

udevadm monitor --property --subsystem-match=power_supply 2>/dev/null | while read -r line; do
    if echo "$line" | grep -q "POWER_SUPPLY_ONLINE"; then
        update_mode
    fi
done
