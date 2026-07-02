#!/bin/bash
exec 3<>/dev/tcp/127.0.0.1/10000
while IFS= read -r line <&3; do
    layer=$(echo "$line" | sed -n 's/.*"new":"\([^"]*\)".*/\1/p')
    [ -z "$layer" ] && continue
    case "$layer" in
        base)       text="INSERT"; cls="" ;;
        vim-normal) text="NORMAL"; cls="layer-vim-normal" ;;
        symbol)     text="SYMBOL"; cls="layer-symbol" ;;
        *)          text="$layer"; cls="layer-$layer" ;;
    esac
    echo "{\"text\": \"$text\", \"class\": \"$cls\"}"
done
