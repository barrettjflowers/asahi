#!/bin/bash

state_file="/tmp/hide_windows_state"
hidden_ws=88

if [ -f "$state_file" ]; then
    original_ws=$(cat "$state_file")
    hyprctl clients -j | jq -r --argjson ws "$hidden_ws" '.[] | select(.workspace.id == $ws and .pid > 0) | .pid' | while read pid; do
        hyprctl dispatch movetoworkspacesilent "$original_ws",pid:"$pid"
    done
    rm -f "$state_file"
else
    current_ws=$(hyprctl activeworkspace -j | jq '.id')
    echo "$current_ws" > "$state_file"
    hyprctl clients -j | jq -r --argjson ws "$current_ws" '.[] | select(.workspace.id == $ws and .pid > 0) | .pid' | while read pid; do
        hyprctl dispatch movetoworkspacesilent "$hidden_ws",pid:"$pid"
    done
fi
