#!/bin/bash
PIDFILE=/tmp/wf-recorder-pid
OUTDIR=$HOME/Pictures/Screenshots

if [ -f "$PIDFILE" ]; then
    kill "$(cat "$PIDFILE")" 2>/dev/null
    rm "$PIDFILE"
    exit 0
fi

mkdir -p "$OUTDIR"
OUTFILE="$OUTDIR/recording_$(date +%Y%m%d_%H%M%S).mp4"
wf-recorder -a -f "$OUTFILE" &
echo $! > "$PIDFILE"
