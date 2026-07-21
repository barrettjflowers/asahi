#!/bin/bash
PIDFILE=/tmp/wf-recorder-pid

if [ ! -f "$PIDFILE" ]; then
    notify-send "Recording" "No active recording"
    exit 1
fi

read -r PID < "$PIDFILE"

if [ -z "$PID" ]; then
    notify-send "Recording" "No active recording"
    exit 1
fi

kill -USR1 "$PID" 2>/dev/null || notify-send "Recording" "No active recording"
