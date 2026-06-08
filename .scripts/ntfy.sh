#!/usr/bin/env bash

echo -e "NOTIFIED TELEGRAM"

if [ -t 0 ]; then
  TEXT="CLI Notification Triggered"
else
  TEXT=$(cat -)
fi

curl -s -X POST -H "Content-Type:multipart/form-data" \
  -F chat_id=REDACTED \
  -F text="$TEXT" \
  "https://api.telegram.org/bot$TG_TOKEN/sendMessage"
