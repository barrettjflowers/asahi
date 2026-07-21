#!/bin/bash

word=$(shuf /usr/share/dict/words | rofi -dmenu -p "Dictionary" -i -l 15)
[ -z "$word" ] && exit 0

encoded=$(printf '%s' "$word" | jq -sRr @uri)
result=$(curl -sf "https://api.dictionaryapi.dev/api/v2/entries/en/$encoded")

if [ -z "$result" ]; then
    notify-send "Dictionary" "No definition found for '$word'"
    exit 1
fi

echo "$result" | jq -r '
    .[0] |
    "Word: \(.word)  \(.phonetic // "")\n" +
    ([.meanings[] |
        "\n▸ \(.partOfSpeech):\n" +
        ([.definitions[:2][] |
            "  - \(.definition)" +
            (if .example then "\n    \"\(.example)\"" else "" end)
        ] | join("\n"))
    ] | join(""))
' | rofi -dmenu -p "Definition: $word"
