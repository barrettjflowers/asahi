#!/bin/bash
# This script is used to browse an array of links and open them in the default browser.

links=(
    "indygateway.net/super"
    "crmaccess.vtiger.com/log-in/"
    "freshdesk.com"
		"app.screencast.com"
		"support.indyhost.net/a/dashboard/default"
)

selected=$(printf '%s\n' "${links[@]}" | fzf --height=10 --no-color --no-preview --multi --print-query --prompt="Select link(s): ")

if [ -z "$selected" ]; then
    exit 0
fi

echo "$selected" | while read -r link; do
    echo "Opening $link"
    if [[ " ${links[*]} " =~ " ${link} " ]]; then
        vivaldi --new-window "https://$link" &
    elif [[ "$link" =~ ^https?:// ]]; then
        vivaldi --new-window "$link" &
    else
        vivaldi --new-window "https://www.google.com/search?q=$(echo "$link" | sed 's/ /+/g')" &
    fi
done
