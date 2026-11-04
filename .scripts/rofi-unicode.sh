#!/bin/bash
# Unicode picker: search characters by name in rofi, copy the selection.
# Recently picked characters are listed first.

data=/usr/share/unicode/ucd/UnicodeData.txt
cache="${XDG_CACHE_HOME:-$HOME/.cache}/rofi-unicode"
list="$cache/list"
recent="$cache/recent"
mkdir -p "$cache"
touch "$recent"

# Rebuild the character list when missing or older than the Unicode data
if [ ! -s "$list" ] || [ "$data" -nt "$list" ]; then
    python3 -I - "$data" > "$list" <<'EOF'
import sys
skip = {"Cc", "Cs", "Co", "Cn"}
for line in open(sys.argv[1], encoding="utf-8"):
    f = line.split(";")
    code, name, cat, old = f[0], f[1], f[2], f[10]
    if name.startswith("<") or cat in skip:
        continue
    alias = f"  ({old.lower()})" if old and old != name else ""
    print(f"{chr(int(code, 16))}  {name.lower()}{alias}  U+{code}")
EOF
fi

choice=$(cat "$recent" "$list" | awk '!seen[$0]++' | rofi -dmenu -i -p "Unicode" -l 15)
[ -z "$choice" ] && exit 0

char="${choice%%  *}"
printf '%s' "$char" | wl-copy -n
notify-send "Unicode" "Copied $char"

# Move the pick to the top of the recent list, keep 30
{ echo "$choice"; grep -vxF -- "$choice" "$recent"; } | head -n 30 > "$recent.tmp" && mv "$recent.tmp" "$recent"
