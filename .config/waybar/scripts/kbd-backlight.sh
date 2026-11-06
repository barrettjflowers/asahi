#!/bin/bash
# Keyboard backlight toggle for the waybar "Backlight" module.
# No args: print JSON status. "toggle": switch between off and 100%.
dev=kbd_backlight

if [ "$1" = toggle ]; then
    if [ "$(brightnessctl -d $dev g)" -gt 0 ]; then
        brightnessctl -q -d $dev s 0
    else
        brightnessctl -q -d $dev s 20%
    fi
    pkill -SIGRTMIN+9 waybar
    exit
fi

pct=$(brightnessctl -m -d $dev i | cut -d, -f4)
if [ "$pct" = 0% ]; then state=Off; else state=On; fi
printf '{"text":"󰌌 Backlight","tooltip":"%s, %s","class":"%s"}\n' "$state" "$pct" "${state,,}"
