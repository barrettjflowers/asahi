#!/bin/bash
# Bar shows /; tooltip adds a line per mounted /mnt/* entry
line() { df -B1 --output=used,size "$1" | awk -v p="$1" 'NR==2{printf "%s %.1f/%.1fGB", p, $1/1e9, $2/1e9}'; }
text=$(df -B1 --output=used,size / | awk 'NR==2{printf "%.1f/%.1fGB", $1/1e9, $2/1e9}')
tip=$(line /)
for m in /mnt/*; do
    mountpoint -q "$m" && tip+="\\n$(line "$m")"
done
printf '{"text":"%s","tooltip":"%s"}\n' "$text" "$tip"
