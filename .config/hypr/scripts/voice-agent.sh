#!/bin/bash
PIDFILE=/tmp/voice-agent-vocal.pid
VOICE="${VOICE_AGENT_VOICE:-en-IE-EmilyNeural}"
RATE="${VOICE_AGENT_RATE:-+0%}"
EDGE_TTS=/home/barrettjflowers/.local/bin/edge-tts
[ -x "$EDGE_TTS" ] || { notify-send "Voice agent" "edge-tts not found"; exit 1; }
MPV=$(command -v mpv) || { notify-send "Voice agent" "mpv not found"; exit 1; }

if [ -f "$PIDFILE" ]; then
    PID=$(cat "$PIDFILE")
    if kill -0 "$PID" 2>/dev/null; then
        kill "$PID" 2>/dev/null
        rm -f "$PIDFILE"
        notify-send "Voice agent" "Stopped"
        exit 0
    fi
    rm -f "$PIDFILE"
fi

text=$(wl-paste 2>/dev/null)
[ -z "$text" ] && { notify-send "Voice agent" "Clipboard empty"; exit 0; }

text="${text#"${text%%[![:space:]]*}"}"
text="${text%"${text##*[![:space:]]}"}"

notify-send "Voice agent" "Speaking clipboard..."
"$EDGE_TTS" --voice "$VOICE" --rate "$RATE" --text "$text" 2>/dev/null | "$MPV" --no-video --really-quiet --force-media-title="Voice agent" - 2>/dev/null &
echo $! > "$PIDFILE"