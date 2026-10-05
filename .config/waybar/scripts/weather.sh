#!/bin/bash
# Runs continuously (no waybar "interval"): prints a line whenever the value changes state.
# Always prints something (last known temp, or a placeholder) so the module never disappears,
# and retries every 5s on failure so it recovers right after wake instead of waiting 10 min.
url="https://api.open-meteo.com/v1/forecast?latitude=39.7684&longitude=-86.1581&current=temperature_2m&temperature_unit=fahrenheit"
cache="${XDG_CACHE_HOME:-$HOME/.cache}/waybar-weather"
last=$(cat "$cache" 2>/dev/null)
next=0

while true; do
    # wall clock, so time spent suspended counts and a wake triggers a fetch
    now=$(date +%s)
    if (( now >= next )); then
        temp=$(curl -s -m 10 "$url" | jq -r '.current.temperature_2m | "\(.)°F"' 2>/dev/null)
        if [[ $temp =~ ^-?[0-9] ]]; then
            last=$temp
            echo "$temp" > "$cache"
            next=$(( now + 600 ))
        else
            next=$(( now + 5 ))
        fi
        echo "${last:---°F}"
    fi
    sleep 5
done
