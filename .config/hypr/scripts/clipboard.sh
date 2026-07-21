#!/bin/bash
chosen=$(cliphist list | rofi -dmenu -p "Clipboard" -i -theme ~/.config/rofi/config.rasi)
if [ -n "$chosen" ]; then
  echo "$chosen" | cliphist decode | wl-copy
  ydotool key ctrl+v
fi
