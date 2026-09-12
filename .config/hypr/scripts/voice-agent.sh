#!/bin/bash
text=$(wl-paste 2>/dev/null)

if [ -z "$text" ]; then
    notify-send "Voice agent" "Clipboard empty"
    exit 0
fi

notify-send "Voice agent" "Asking big-pickle..."
LOG=/tmp/voice-agent-debug.log
reply=$(
    /home/barrettjflowers/.opencode/bin/opencode run -c --dir "$HOME" -m opencode/big-pickle --format json -- "$text. Respond concisely in plain text only. Do not use any tools." > "$LOG" 2>&1
    python3 -c '
import json, sys
best = ""
for line in sys.stdin:
    line = line.strip()
    if not line:
        continue
    try:
        ev = json.loads(line)
    except Exception:
        continue
    if ev.get("type") == "message.updated":
        msg = ev.get("message", {})
        if msg.get("role") == "assistant":
            parts = "".join(p.get("text", "") or "" for p in msg.get("content", []))
            if parts:
                best = parts
sys.stdout.write(best)
' < "$LOG"
)

if [ -z "$reply" ]; then
    notify-send "Voice agent" "Got no reply (see /tmp/voice-agent-debug.log)"
    exit 1
fi
echo -n "$reply" | wl-copy

EDGE_TTS=/home/barrettjflowers/.local/bin/edge-tts
TTS=/tmp/voice-agent-reply.mp3
$EDGE_TTS --voice en-US-JennyNeural --text "$reply" --write-media "$TTS" 2>/dev/null
[ -f "$TTS" ] && mpv --no-video --really-quiet "$TTS" 2>/dev/null &
notify-send "Voice agent" "$reply"
