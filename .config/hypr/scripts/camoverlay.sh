#!/bin/bash
PIDFILE=/tmp/camoverlay-pid

if [ -f "$PIDFILE" ]; then
    kill "$(cat "$PIDFILE")" 2>/dev/null
    rm "$PIDFILE"
    exit 0
fi

mpv --no-audio \
    --profile=low-latency \
    --no-border \
    --ontop \
    --title="camera-overlay" \
    --geometry=620x349 \
    av://v4l2:/dev/video0 &
echo $! > "$PIDFILE"
