#!/usr/bin/env bash

set -euo pipefail

CHAT_ID=6739543348
API="https://api.telegram.org/bot$TG_TOKEN"
POLL_INTERVAL=3
OFFSET_FILE="${TMPDIR:-/tmp}/telegram-opencode-offset"

get_offset() {
  if [ -f "$OFFSET_FILE" ]; then
    cat "$OFFSET_FILE"
  else
    echo "0"
  fi
}

save_offset() {
  echo "$1" > "$OFFSET_FILE"
}

send_message() {
  local text="$1"
  curl -s -X POST -H "Content-Type:multipart/form-data" \
    -F "chat_id=$CHAT_ID" \
    -F "text=$text" \
    "$API/sendMessage" > /dev/null
}

notify_start() {
  send_message "🤖 opencode listener started. Send me a message and I'll run it."
}

handle_message() {
  local text="$1"

  if [ -z "$text" ]; then
    return
  fi

  case "$text" in
    "/help"|"/start")
      send_message "Send me any prompt and I'll run it with \`opencode run\`.\nCommands:\n/status - check if I'm alive\n/stop - shutdown listener"
      return
      ;;
    "/status")
      send_message "🟢 I'm alive and listening."
      return
      ;;
    "/stop")
      send_message "👋 Shutting down listener."
      exit 0
      ;;
  esac

  send_message "🤖 Running: \`$text\`"

  local output
  output=$(opencode run "$text" 2>&1 || true)

  send_message "✅ Response:\n\`\`\`$output\`\`\`"
}

notify_start

offset=$(get_offset)

while true; do
  updates=$(curl -s "$API/getUpdates?offset=$offset&timeout=25")

  if command -v jq > /dev/null 2>&1 && echo "$updates" | jq -e '.ok == true' > /dev/null 2>&1; then
    count=$(echo "$updates" | jq '.result | length')
    for ((i = 0; i < count; i++)); do
      update=$(echo "$updates" | jq -c ".result[$i]")
      msg_id=$(echo "$update" | jq -r '.update_id')
      chat_id=$(echo "$update" | jq -r '.message.chat.id // empty')
      text=$(echo "$update" | jq -r '.message.text // empty')

      [ -z "$chat_id" ] || [ "$chat_id" != "$CHAT_ID" ] && continue

      [ -n "$text" ] && handle_message "$text"

      offset=$((msg_id + 1))
      save_offset "$offset"
    done
  fi

  sleep "$POLL_INTERVAL"
done
